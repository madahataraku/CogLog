#!/usr/bin/env python3
"""Convert YOLO-txt digit detection labels to COCO JSON for SSCMA.

Expected layout (Roboflow / LibreYOLO style)::

    <root>/
      train/images/*.jpg
      train/labels/*.txt
      valid/images/*.jpg   # or val/
      valid/labels/*.txt

Each label line is ``class_id x_center y_center width height`` (normalized).

Output layout (SSCMA CustomYOLOv5CocoDataset)::

    <out>/
      train/_annotations.coco.json
      train/<image files>
      valid/_annotations.coco.json
      valid/<image files>
"""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path
from typing import Iterable


IMAGE_SUFFIXES = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}


def _die(message: str, code: int = 1) -> int:
    print(message)
    return code


def _split_dirs(root: Path) -> list[tuple[str, Path, Path]]:
    """Return (split_name, images_dir, labels_dir) for train/valid."""
    found: list[tuple[str, Path, Path]] = []
    for name, out_name in (("train", "train"), ("valid", "valid"), ("val", "valid")):
        images = root / name / "images"
        labels = root / name / "labels"
        if images.is_dir() and labels.is_dir():
            if out_name == "valid" and any(s[0] == "valid" for s in found):
                continue
            found.append((out_name, images, labels))
    return found


def _image_size(path: Path) -> tuple[int, int]:
    # Pillow 無しでも動くよう、PNG/JPEG の最小ヘッダだけ見るのは脆いので
    # 変換時は必須依存にせず、失敗時は例外にする。
    try:
        from PIL import Image  # type: ignore
    except ImportError as exc:  # pragma: no cover
        raise RuntimeError(
            "Pillow is required to read image sizes. pip install pillow"
        ) from exc
    with Image.open(path) as img:
        width, height = img.size
    return int(width), int(height)


def _iter_images(images_dir: Path) -> Iterable[Path]:
    for path in sorted(images_dir.iterdir()):
        if path.is_file() and path.suffix.lower() in IMAGE_SUFFIXES:
            yield path


def _read_yolo_labels(label_path: Path) -> list[tuple[int, float, float, float, float]]:
    if not label_path.is_file():
        return []
    rows: list[tuple[int, float, float, float, float]] = []
    for line in label_path.read_text(encoding="utf-8").splitlines():
        text = line.strip()
        if not text:
            continue
        parts = text.split()
        if len(parts) != 5:
            raise ValueError(f"Bad YOLO line in {label_path}: {text!r}")
        class_id = int(float(parts[0]))
        xc, yc, w, h = (float(parts[1]), float(parts[2]), float(parts[3]), float(parts[4]))
        rows.append((class_id, xc, yc, w, h))
    return rows


def _yolo_to_coco_bbox(
    xc: float,
    yc: float,
    w: float,
    h: float,
    img_w: int,
    img_h: int,
) -> list[float]:
    abs_w = w * img_w
    abs_h = h * img_h
    x = (xc * img_w) - abs_w / 2.0
    y = (yc * img_h) - abs_h / 2.0
    return [x, y, abs_w, abs_h]


def convert_split(
    *,
    split_name: str,
    images_dir: Path,
    labels_dir: Path,
    out_split_dir: Path,
    class_names: list[str],
    copy_images: bool,
) -> dict:
    out_split_dir.mkdir(parents=True, exist_ok=True)
    categories = [
        {"id": i, "name": name, "supercategory": "digit"}
        for i, name in enumerate(class_names)
    ]
    images: list[dict] = []
    annotations: list[dict] = []
    ann_id = 1
    for image_id, image_path in enumerate(_iter_images(images_dir), start=1):
        width, height = _image_size(image_path)
        file_name = image_path.name
        dest = out_split_dir / file_name
        if copy_images:
            if not dest.exists() or dest.resolve() != image_path.resolve():
                shutil.copy2(image_path, dest)
        else:
            if not dest.exists():
                dest.symlink_to(image_path.resolve())
        images.append(
            {
                "id": image_id,
                "file_name": file_name,
                "width": width,
                "height": height,
            }
        )
        label_path = labels_dir / f"{image_path.stem}.txt"
        for class_id, xc, yc, bw, bh in _read_yolo_labels(label_path):
            if class_id < 0 or class_id >= len(class_names):
                raise ValueError(
                    f"{label_path}: class_id {class_id} out of range "
                    f"for {len(class_names)} classes"
                )
            bbox = _yolo_to_coco_bbox(xc, yc, bw, bh, width, height)
            annotations.append(
                {
                    "id": ann_id,
                    "image_id": image_id,
                    "category_id": class_id,
                    "bbox": bbox,
                    "area": float(bbox[2] * bbox[3]),
                    "iscrowd": 0,
                    "segmentation": [],
                }
            )
            ann_id += 1
    coco = {
        "info": {
            "description": f"CogLog seven-segment COCO ({split_name})",
            "version": "1.0",
        },
        "licenses": [{"id": 1, "name": "see dataset NOTICE / source license"}],
        "images": images,
        "annotations": annotations,
        "categories": categories,
    }
    out_json = out_split_dir / "_annotations.coco.json"
    out_json.write_text(json.dumps(coco), encoding="utf-8")
    return {
        "split": split_name,
        "images": len(images),
        "annotations": len(annotations),
        "json": str(out_json),
    }


def convert_dataset(
    root: Path,
    out: Path,
    class_names: list[str] | None = None,
    *,
    copy_images: bool = True,
) -> list[dict]:
    splits = _split_dirs(root)
    if not splits:
        raise FileNotFoundError(
            f"No train/valid YOLO splits under {root} "
            "(expected <split>/images and <split>/labels)"
        )
    names = class_names or [str(i) for i in range(10)]
    out.mkdir(parents=True, exist_ok=True)
    summaries: list[dict] = []
    for split_name, images_dir, labels_dir in splits:
        summaries.append(
            convert_split(
                split_name=split_name,
                images_dir=images_dir,
                labels_dir=labels_dir,
                out_split_dir=out / split_name,
                class_names=names,
                copy_images=copy_images,
            )
        )
    return summaries


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=True, help="YOLO dataset root")
    parser.add_argument("--out", type=Path, required=True, help="COCO output root")
    parser.add_argument(
        "--classes",
        default="0,1,2,3,4,5,6,7,8,9",
        help="Comma-separated class names in id order (default: 0-9)",
    )
    parser.add_argument(
        "--symlink-images",
        action="store_true",
        help="Symlink images instead of copying (saves disk)",
    )
    args = parser.parse_args()
    class_names = [c.strip() for c in args.classes.split(",") if c.strip()]
    if not class_names:
        return _die("--classes must not be empty")
    try:
        summaries = convert_dataset(
            args.root.resolve(),
            args.out.resolve(),
            class_names,
            copy_images=not args.symlink_images,
        )
    except (FileNotFoundError, ValueError, RuntimeError) as exc:
        return _die(str(exc))
    for row in summaries:
        print(
            f"{row['split']}: images={row['images']} "
            f"annotations={row['annotations']} -> {row['json']}"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
