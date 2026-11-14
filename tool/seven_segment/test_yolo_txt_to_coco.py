#!/usr/bin/env python3
"""Tests for yolo_txt_to_coco and treadmill remapping (stdlib + Pillow)."""

from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from remap_treadmill_ocr_labels import (  # noqa: E402
    DEFAULT_NAMES,
    class_id_to_digit,
    remap_label_file,
)
from yolo_txt_to_coco import convert_dataset  # noqa: E402


class YoloTxtToCocoTest(unittest.TestCase):
    def test_converts_normalized_boxes(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "yolo"
            for split in ("train", "valid"):
                (root / split / "images").mkdir(parents=True)
                (root / split / "labels").mkdir(parents=True)
                img = root / split / "images" / "a.jpg"
                Image.new("RGB", (100, 50), color=(0, 0, 0)).save(img)
                (root / split / "labels" / "a.txt").write_text(
                    "3 0.5 0.5 0.2 0.4\n", encoding="utf-8"
                )
            out = Path(tmp) / "coco"
            summaries = convert_dataset(root, out)
            self.assertEqual(len(summaries), 2)
            coco = json.loads(
                (out / "train" / "_annotations.coco.json").read_text(encoding="utf-8")
            )
            self.assertEqual(len(coco["images"]), 1)
            self.assertEqual(len(coco["annotations"]), 1)
            self.assertEqual(coco["annotations"][0]["category_id"], 3)
            bbox = coco["annotations"][0]["bbox"]
            self.assertAlmostEqual(bbox[0], 40.0)
            self.assertAlmostEqual(bbox[1], 15.0)
            self.assertAlmostEqual(bbox[2], 20.0)
            self.assertAlmostEqual(bbox[3], 20.0)


class RemapTreadmillTest(unittest.TestCase):
    def test_maps_font_variants_and_drops_symbols(self) -> None:
        self.assertEqual(class_id_to_digit(DEFAULT_NAMES.index("zero_"), DEFAULT_NAMES), 0)
        self.assertEqual(class_id_to_digit(DEFAULT_NAMES.index("nine."), DEFAULT_NAMES), 9)
        self.assertIsNone(class_id_to_digit(DEFAULT_NAMES.index("colon_"), DEFAULT_NAMES))
        with tempfile.TemporaryDirectory() as tmp:
            src = Path(tmp) / "in.txt"
            dest = Path(tmp) / "out.txt"
            zero = DEFAULT_NAMES.index("zero_")
            colon = DEFAULT_NAMES.index("colon_")
            src.write_text(
                f"{zero} 0.1 0.2 0.3 0.4\n{colon} 0.5 0.5 0.1 0.1\n",
                encoding="utf-8",
            )
            kept, dropped = remap_label_file(src, dest, DEFAULT_NAMES)
            self.assertEqual(kept, 1)
            self.assertEqual(dropped, 1)
            self.assertEqual(
                dest.read_text(encoding="utf-8").strip(),
                "0 0.1 0.2 0.3 0.4",
            )


if __name__ == "__main__":
    raise SystemExit(unittest.main())
