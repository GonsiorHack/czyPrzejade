import os
import random
from collections import defaultdict
from pathlib import Path

import torch
import torchvision.transforms.functional as TF
from PIL import Image
from torch import nn, optim
from torch.utils.data import DataLoader
from torchvision import datasets, models, transforms

from image_transforms import create_eval_transform

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data/learning"
MODEL_PATH = BASE_DIR / "surface_model.pth"
BATCH_SIZE = 4
EPOCHS = 25
LEARNING_RATE = 0.0003
TRAIN_RATIO = 0.8

CATEGORY_SCORES = {
    "stairs0": {
        "clean_name": "stairs",
        "score": 0.0
    },
    "cobblestone2": {
        "clean_name": "cobblestone",
        "score": 0.2
    },
    "concrete10": {
        "clean_name": "concrete",
        "score": 1.0
    }
}

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Urządzenie: {device}")


class RandomDiscreteRotation:
    def __init__(self, angles=None):
        self.angles = [0, 90, 180, 270] if angles is None else angles

    def __call__(self, image):
        angle = random.choice(self.angles)
        return TF.rotate(image, angle)


class RandomSquareCrop:
    def __call__(self, image):
        width, height = image.size
        crop_size = min(width, height)
        if width == height:
            return image
        if width > height:
            left = random.randint(0, width - crop_size)
            return image.crop((left, 0, left + crop_size, height))

        top = random.randint(0, height - crop_size)
        return image.crop((0, top, width, top + crop_size))


train_transform = transforms.Compose([
    RandomSquareCrop(),
    transforms.Resize((224, 224)),
    RandomDiscreteRotation([0, 90, 180, 270]),
    transforms.RandomHorizontalFlip(p=0.5),
    transforms.RandomVerticalFlip(p=0.5),

    transforms.ColorJitter(
        brightness=(0.4, 1.3),
        contrast=(0.6, 1.4),
        saturation=(0.7, 1.3)
    ),
    transforms.RandomGrayscale(p=0.25),

    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
])

val_transform = create_eval_transform()

if not 0 < TRAIN_RATIO < 1:
    raise ValueError("TRAIN_RATIO musi być większe od 0 i mniejsze od 1.")
if BATCH_SIZE < 2 or EPOCHS < 1:
    raise ValueError("BATCH_SIZE musi wynosić co najmniej 2, a EPOCHS co najmniej 1.")
full_dataset = datasets.ImageFolder(root=DATA_DIR)
class_names = full_dataset.classes
missing_scores = set(class_names) - CATEGORY_SCORES.keys()
if missing_scores:
    raise ValueError(f"Brak CATEGORY_SCORES dla klas: {sorted(missing_scores)}.")
print(f"Wykryte klasy: {class_names}")

class_indices = defaultdict(list)
for idx, (_, label) in enumerate(full_dataset.samples):
    class_indices[label].append(idx)

train_indices = []
val_indices = []

random.seed(42)

print("\nPodział danych:")
for label, indices in class_indices.items():
    random.shuffle(indices)
    # Pojedyncze zdjęcie zostaje w treningu, nie w walidacji.
    split_point = max(1, int(len(indices) * TRAIN_RATIO))
    train_idx = indices[:split_point]
    val_idx = indices[split_point:]

    train_indices.extend(train_idx)
    val_indices.extend(val_idx)
    print(
        f"Klasa '{class_names[label]}': {len(indices)} zdjęć, "
        f"trening: {len(train_idx)}, walidacja: {len(val_idx)}"
    )


class ImageDataset(torch.utils.data.Dataset):
    def __init__(self, dataset, indices, transform):
        self.dataset = dataset
        self.indices = indices
        self.transform = transform

    def __getitem__(self, index):
        sample_index = self.indices[index]
        image_path, label = self.dataset.samples[sample_index]
        with Image.open(image_path) as source:
            image = source.convert("RGB")
        if self.transform:
            image = self.transform(image)
        return image, label, image_path

    def __len__(self):
        return len(self.indices)


train_data = ImageDataset(full_dataset, train_indices, train_transform)
val_data = ImageDataset(full_dataset, val_indices, val_transform)
if not val_data:
    raise ValueError(
        "Zbiór walidacyjny jest pusty. Dodaj zdjęcia, aby można było wybrać najlepszy model."
    )

# Pomijamy niepełną partię, by BatchNorm nie liczył statystyk z jednego zdjęcia.
train_loader = DataLoader(train_data, batch_size=BATCH_SIZE, shuffle=True, drop_last=True)
val_loader = DataLoader(val_data, batch_size=BATCH_SIZE, shuffle=False)

if len(train_loader) == 0:
    raise ValueError(
        f"Zbiór treningowy ma {len(train_data)} zdjęć, mniej niż BATCH_SIZE={BATCH_SIZE}. "
        "Przy drop_last=True nie powstanie żadna partia. Dodaj zdjęcia lub zmniejsz BATCH_SIZE."
    )

model = models.mobilenet_v2(weights=models.MobileNet_V2_Weights.DEFAULT)

for param in model.parameters():
    param.requires_grad = False

for param in model.features[-1].parameters():
    param.requires_grad = True

frozen_batchnorm_layers = [
    layer
    for layer in model.features.modules()
    if isinstance(layer, nn.BatchNorm2d)
    and not any(param.requires_grad for param in layer.parameters())
]

num_classes = len(class_names)
model.classifier[1] = nn.Linear(model.classifier[1].in_features, num_classes)

for param in model.classifier.parameters():
    param.requires_grad = True

model = model.to(device)

criterion = nn.CrossEntropyLoss()

optimizer = optim.Adam([
    {"params": model.features[-1].parameters(), "lr": 0.00005},
    {"params": model.classifier.parameters(), "lr": LEARNING_RATE}
])

print(f"\nRozpoczynam trening: {EPOCHS} epok.\n")

best_val_loss = float("inf")
best_val_acc = 0.0
best_model_weights = None

for epoch in range(EPOCHS):
    model.train()
    # Zamrożony BatchNorm ma zachować statystyki z ImageNet także po model.train().
    for layer in frozen_batchnorm_layers:
        layer.eval()
    running_loss = 0.0
    correct_train = 0
    total_train = 0

    for images, labels, _ in train_loader:
        images, labels = images.to(device), labels.to(device)

        optimizer.zero_grad()
        outputs = model(images)
        loss = criterion(outputs, labels)
        if not torch.isfinite(loss).item():
            raise ValueError(f"Nieskończona lub NaN strata treningowa w epoce {epoch + 1}.")
        loss.backward()
        optimizer.step()

        running_loss += loss.item() * images.size(0)
        _, preds = torch.max(outputs, 1)
        correct_train += torch.sum(preds == labels)
        total_train += labels.size(0)

    train_loss = running_loss / total_train
    train_acc = (correct_train.double() / total_train).item() * 100

    model.eval()
    val_running_loss = 0.0
    correct_val = 0
    total_val = 0

    with torch.no_grad():
        for images, labels, _ in val_loader:
            images, labels = images.to(device), labels.to(device)
            outputs = model(images)
            loss = criterion(outputs, labels)
            if not torch.isfinite(loss).item():
                raise ValueError(f"Nieskończona lub NaN strata walidacyjna w epoce {epoch + 1}.")

            val_running_loss += loss.item() * images.size(0)
            _, preds = torch.max(outputs, 1)
            correct_val += torch.sum(preds == labels)
            total_val += labels.size(0)

    val_loss = val_running_loss / total_val
    val_acc = (correct_val.double() / total_val).item() * 100

    marker = ""
    if val_loss < best_val_loss:
        best_val_loss = val_loss
        best_val_acc = val_acc
        best_model_weights = {k: v.cpu().clone() for k, v in model.state_dict().items()}
        marker = " [najniższa strata walidacyjna]"

    print(
        f"Epoka [{epoch + 1:02d}/{EPOCHS:02d}] - "
        f"train_loss: {train_loss:.4f}, trafność: {train_acc:5.1f}% | "
        f"val_loss: {val_loss:.4f}, trafność: {val_acc:5.1f}%{marker}"
    )

if best_model_weights is not None:
    model.load_state_dict({k: v.to(device) for k, v in best_model_weights.items()})
    print(
        f"\nPrzywrócono najlepsze wagi: val_loss={best_val_loss:.4f}, "
        f"trafność walidacyjna={best_val_acc:.1f}%."
    )

print("\nBłędy klasyfikacji w zbiorze walidacyjnym:")

model.eval()
errors_found = 0
correct_per_class = defaultdict(int)
total_per_class = defaultdict(int)

with torch.no_grad():
    for images, labels, paths in val_loader:
        images, labels = images.to(device), labels.to(device)
        outputs = model(images)
        probs = torch.nn.functional.softmax(outputs, dim=1)
        confidences, preds = torch.max(probs, 1)

        for true_label, pred_label, conf, path in zip(labels, preds, confidences, paths):
            c_true = class_names[true_label.item()]
            c_pred = class_names[pred_label.item()]
            total_per_class[c_true] += 1

            if true_label == pred_label:
                correct_per_class[c_true] += 1
            else:
                errors_found += 1
                filename = os.path.basename(path)
                print(f"\nPlik: {filename}")
                print(f"  Ścieżka: {path}")
                print(f"  Klasa rzeczywista: {c_true}")
                print(f"  Predykcja: {c_pred} (pewność: {conf.item() * 100:.1f}%)")

print("\nTrafność według klas:")
for c_name in class_names:
    total = total_per_class[c_name]
    correct = correct_per_class[c_name]
    if total == 0:
        print(f"Klasa '{c_name}': brak zdjęć walidacyjnych.")
        continue
    acc = correct / total * 100
    print(f"Klasa '{c_name}': {correct}/{total} poprawnych predykcji ({acc:.1f}%)")

if errors_found == 0:
    print("\nNie znaleziono błędnych predykcji.")

torch.save({
    "model_state_dict": model.state_dict(),
    "class_names": class_names,
    "category_scores": CATEGORY_SCORES
}, MODEL_PATH)
print(f"\nModel zapisano w pliku '{MODEL_PATH}'.")