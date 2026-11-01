import json
import math
from pathlib import Path

import torch
from PIL import Image
from torch import nn
from torchvision import models

from image_transforms import create_eval_transform


BASE_DIR = Path(__file__).resolve().parent
INPUT_DIR = BASE_DIR / "data/map_data"
OUTPUT_DIR = BASE_DIR / "analyzed_data"
MODEL_PATH = BASE_DIR / "surface_model.pth"
PASSABILITY_THRESHOLD = 0.4

IMAGE_EXTENSIONS = {".png", ".jpg", ".jpeg", ".webp", ".bmp"}
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

print(f"Wczytuję model z pliku '{MODEL_PATH}'...")
checkpoint = torch.load(MODEL_PATH, map_location=device)
class_names = checkpoint["class_names"]
category_scores = checkpoint["category_scores"]
for class_name in class_names:
    if class_name not in category_scores:
        raise ValueError(f"Brak oceny przejezdności dla klasy '{class_name}'.")
    class_info = category_scores[class_name]
    score = class_info["score"]
    if not isinstance(score, (int, float)) or not math.isfinite(score) or not 0 <= score <= 1:
        raise ValueError(f"Niepoprawna ocena przejezdności dla klasy '{class_name}': {score}.")

model = models.mobilenet_v2()
model.classifier[1] = nn.Linear(model.classifier[1].in_features, len(class_names))
model.load_state_dict(checkpoint["model_state_dict"])
model = model.to(device)
model.eval()

infer_transform = create_eval_transform()


def classify_image(image_path: Path):
    with Image.open(image_path) as source:
        image = source.convert("RGB")
    tensor = infer_transform(image).unsqueeze(0).to(device)

    with torch.no_grad():
        outputs = model(tensor)
        if not torch.isfinite(outputs).all().item():
            raise ValueError(f"Model zwrócił NaN lub nieskończony wynik dla '{image_path}'.")
        probabilities = torch.nn.functional.softmax(outputs[0], dim=0)

    class_index = torch.argmax(probabilities).item()
    class_name = class_names[class_index]
    confidence = probabilities[class_index].item()
    class_info = category_scores[class_name]
    return {
        "surface_detected": class_info["clean_name"],
        "passability_score": class_info["score"],
        "ml_confidence": round(confidence, 2)
    }


def analizuj_strefy() -> None:
    if not INPUT_DIR.is_dir():
        raise NotADirectoryError(f"Katalog '{INPUT_DIR}' nie istnieje lub nie jest katalogiem.")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    wszystkie_obiekty = []

    katalogi_stref = [katalog for katalog in INPUT_DIR.iterdir() if katalog.is_dir()]
    try:
        katalogi_stref.sort(key=lambda katalog: int(katalog.name))
    except ValueError:
        katalogi_stref.sort()

    print(f"Analizuję {len(katalogi_stref)} stref z katalogu '{INPUT_DIR}'.\n")

    for katalog in katalogi_stref:
        identyfikator_strefy = katalog.name

        pliki_geojson = sorted(
            plik for plik in katalog.iterdir()
            if plik.is_file() and plik.suffix.lower() == ".geojson"
        ) + sorted(
            plik for plik in katalog.iterdir()
            if plik.is_file() and plik.suffix.lower() == ".json"
        )
        if not pliki_geojson:
            print(f"Strefa {identyfikator_strefy}: brak pliku GeoJSON, pomijam.")
            continue
        sciezka_geojson = pliki_geojson[0]

        zdjecia = sorted(
            plik for plik in katalog.iterdir()
            if plik.is_file() and plik.suffix.lower() in IMAGE_EXTENSIONS
        )
        if not zdjecia:
            print(f"Strefa {identyfikator_strefy}: brak zdjęcia, pomijam.")
            continue
        sciezka_zdjecia = zdjecia[0]
        if len(pliki_geojson) > 1 or len(zdjecia) > 1:
            print(
                f"Strefa {identyfikator_strefy}: znaleziono kilka plików; "
                f"wybrano '{sciezka_geojson.name}' i '{sciezka_zdjecia.name}'."
            )

        wynik = classify_image(sciezka_zdjecia)
        ocena = wynik["passability_score"]
        przejezdna = ocena >= PASSABILITY_THRESHOLD

        with open(sciezka_geojson, "r", encoding="utf-8") as plik:
            dane_geojson = json.load(plik)

        if (
            not isinstance(dane_geojson, dict)
            or dane_geojson.get("type") != "FeatureCollection"
            or not isinstance(dane_geojson.get("features"), list)
            or not dane_geojson["features"]
        ):
            raise ValueError(f"Plik '{sciezka_geojson}' musi zawierać niepusty FeatureCollection.")
        obiekty = dane_geojson["features"]
        for obiekt in obiekty:
            if not isinstance(obiekt, dict) or obiekt.get("type") != "Feature":
                raise ValueError(f"Niepoprawny obiekt Feature w pliku '{sciezka_geojson}'.")
            if obiekt.get("properties") is None:
                obiekt["properties"] = {}
            elif not isinstance(obiekt["properties"], dict):
                raise ValueError(f"Niepoprawne properties w pliku '{sciezka_geojson}'.")

            obiekt["properties"].update({
                "zone_id": identyfikator_strefy,
                "surface_detected": wynik["surface_detected"],
                "passability_score": ocena,
                "threshold_applied": PASSABILITY_THRESHOLD,
                "is_passable_for_wheelchair": przejezdna,
                "avoid": not przejezdna,
                "ml_confidence": wynik["ml_confidence"],
                "source_image": sciezka_zdjecia.name
            })
            wszystkie_obiekty.append(obiekt)

        katalog_wynikowy = OUTPUT_DIR / identyfikator_strefy
        katalog_wynikowy.mkdir(parents=True, exist_ok=True)
        with open(katalog_wynikowy / sciezka_geojson.name, "w", encoding="utf-8") as plik:
            json.dump(dane_geojson, plik, indent=2, ensure_ascii=False)

        status = "przejezdna" if przejezdna else "bariera"
        print(
            f"Strefa {identyfikator_strefy:>2}: {wynik['surface_detected']:<12} "
            f"(pewność: {wynik['ml_confidence'] * 100:4.1f}%, "
            f"ocena: {ocena}) -> {status}"
        )

    if not wszystkie_obiekty:
        raise ValueError("Nie przeanalizowano żadnej geometrii. Sprawdź pliki w katalogach stref.")

    zbiorczy_geojson = {
        "type": "FeatureCollection",
        "name": "Krakow_Accessibility_Zones",
        "features": wszystkie_obiekty
    }
    sciezka_wynikowa = OUTPUT_DIR / "all_zones.geojson"
    with open(sciezka_wynikowa, "w", encoding="utf-8") as plik:
        json.dump(zbiorczy_geojson, plik, indent=2, ensure_ascii=False)

    print(f"\nZbiorczy GeoJSON zapisano w pliku '{sciezka_wynikowa}'.")


if __name__ == "__main__":
    analizuj_strefy()