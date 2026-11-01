import ast
import contextlib
import io
import json
import shutil
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import torch
from PIL import Image
from torchvision import models

from image_transforms import create_eval_transform


class MLTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        source_dir = Path(__file__).resolve().parent
        for name in ("train_model.py", "analyze_map_data.py", "image_transforms.py"):
            shutil.copyfile(source_dir / name, self.root / name)

    def run_script(self, name, **settings):
        path = self.root / name
        tree = ast.parse(path.read_text())
        for node in tree.body:
            if isinstance(node, ast.Assign):
                for target in node.targets:
                    if isinstance(target, ast.Name) and target.id in settings:
                        node.value = ast.Constant(settings[target.id])
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            namespace = {"__file__": str(path), "__name__": "__main__"}
            exec(compile(ast.fix_missing_locations(tree), str(path), "exec"), namespace)
        return namespace, output.getvalue()

    def create_training_data(self, counts):
        for category, count in counts.items():
            folder = self.root / "data/learning" / category
            folder.mkdir(parents=True)
            for index in range(count):
                Image.new("RGB", (240, 320), (index * 10, 100, 200)).save(folder / f"{index}.png")

    def create_checkpoint(self):
        model = models.mobilenet_v2(weights=None)
        model.classifier[1] = torch.nn.Linear(1280, 2)
        torch.save({
            "model_state_dict": model.state_dict(),
            "class_names": ["concrete10", "stairs0"],
            "category_scores": {
                "concrete10": {"clean_name": "concrete", "score": 1.0},
                "stairs0": {"clean_name": "stairs", "score": 0.0},
            },
        }, self.root / "surface_model.pth")

    def test_training_preserves_frozen_buffers_and_saves_best_weights(self):
        self.create_training_data({"concrete10": 6, "cobblestone2": 6, "stairs0": 1})
        model = models.mobilenet_v2(weights=None)
        original_buffers = {
            name: value.clone() for name, value in model.features[:-1].named_buffers()
        }
        with patch("torchvision.models.mobilenet_v2", return_value=model):
            namespace, output = self.run_script("train_model.py", EPOCHS=2)
        saved = torch.load(self.root / "surface_model.pth", map_location="cpu")
        for name, value in model.features[:-1].named_buffers():
            self.assertTrue(torch.equal(value, original_buffers[name]), name)
        for name, value in namespace["best_model_weights"].items():
            self.assertTrue(torch.equal(saved["model_state_dict"][name], value), name)
        self.assertIn("train_loss:", output)
        self.assertIn("val_loss:", output)
        self.assertEqual(len(namespace["train_data"]), 9)
        self.assertEqual(namespace["total_train"], 8)
        self.assertEqual(namespace["total_val"], 4)

    def test_incomplete_training_batch_fails(self):
        self.create_training_data({"concrete10": 2, "stairs0": 2})
        with self.assertRaisesRegex(ValueError, "nie powstanie żadna partia"):
            self.run_script("train_model.py")

    def test_nan_loss_fails_without_checkpoint(self):
        self.create_training_data({"concrete10": 6, "stairs0": 6})
        model = models.mobilenet_v2(weights=None)
        with (
            patch("torchvision.models.mobilenet_v2", return_value=model),
            patch("torch.nn.CrossEntropyLoss") as loss,
        ):
            loss.return_value.return_value = torch.tensor(float("nan"))
            with self.assertRaisesRegex(ValueError, "NaN strata treningowa"):
                self.run_script("train_model.py", EPOCHS=1)
        self.assertFalse((self.root / "surface_model.pth").exists())

    def test_empty_validation_fails_without_checkpoint(self):
        self.create_training_data({"concrete10": 1, "stairs0": 1})
        with self.assertRaisesRegex(ValueError, "walidacyjny jest pusty"):
            self.run_script("train_model.py")
        self.assertFalse((self.root / "surface_model.pth").exists())

    def test_unknown_category_fails_before_training(self):
        self.create_training_data({"unknown": 6})
        with self.assertRaisesRegex(ValueError, "CATEGORY_SCORES"):
            self.run_script("train_model.py")

    def test_eval_transform_crops_without_stretching(self):
        image = Image.new("RGB", (320, 240), "red")
        image.paste(Image.new("RGB", (240, 240), "blue"), (40, 0))
        expected = create_eval_transform()(Image.new("RGB", (240, 240), "blue"))
        self.assertTrue(torch.equal(create_eval_transform()(image), expected))

    def test_analysis_produces_metadata_and_ignores_image_directories(self):
        self.create_checkpoint()
        zone = self.root / "data/map_data/1"
        zone.mkdir(parents=True)
        (zone / "0.png").mkdir()
        Image.new("RGB", (320, 240), "blue").save(zone / "photo.PNG")
        (zone / "zone.GEOJSON").write_text(json.dumps({
            "type": "FeatureCollection",
            "features": [{"type": "Feature", "geometry": None, "properties": None}],
        }))
        namespace, _ = self.run_script("analyze_map_data.py")
        result = json.loads((self.root / "analyzed_data/all_zones.geojson").read_text())
        properties = result["features"][0]["properties"]
        self.assertEqual(properties["source_image"], "photo.PNG")
        self.assertEqual(properties["zone_id"], "1")
        self.assertEqual(properties["avoid"], properties["passability_score"] < 0.4)
        image = Image.new("RGB", (320, 240), "blue")
        self.assertTrue(torch.equal(namespace["infer_transform"](image), create_eval_transform()(image)))

    def test_invalid_geojson_fails_without_combined_result(self):
        self.create_checkpoint()
        zone = self.root / "data/map_data/1"
        zone.mkdir(parents=True)
        Image.new("RGB", (224, 224)).save(zone / "photo.png")
        (zone / "zone.json").write_text('{"type": "Feature", "properties": {}}')
        with self.assertRaisesRegex(ValueError, "FeatureCollection"):
            self.run_script("analyze_map_data.py")
        self.assertFalse((self.root / "analyzed_data/all_zones.geojson").exists())

    def test_missing_input_directory_fails(self):
        self.create_checkpoint()
        with self.assertRaises(NotADirectoryError):
            self.run_script("analyze_map_data.py")


if __name__ == "__main__":
    unittest.main()
