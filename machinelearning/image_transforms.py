from torchvision import transforms


class CenterSquareCrop:
    def __call__(self, image):
        width, height = image.size
        crop_size = min(width, height)
        left = (width - crop_size) // 2
        top = (height - crop_size) // 2
        return image.crop((left, top, left + crop_size, top + crop_size))


def create_eval_transform():
    return transforms.Compose([
        CenterSquareCrop(),
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225],
        ),
    ])
