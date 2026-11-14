#!/usr/bin/env python3
"""Download LibreYOLO/digits-t2eg6 (CC BY 4.0) and convert to SSCMA COCO.

Primary public dataset for CogLog seven-segment Colab retraining:
https://huggingface.co/datasets/LibreYOLO/digits-t2eg6

Classes are digits 0–9 (matches the app TFLite/Core ML contract of 10 classes).
"""

from __future__ import annotations

import argparse
import json
import shutil
import sys
from pathlib import Path

_SCRIPT_DIR = Path(__file__).resolve().parent
if str(_SCRIPT_DIR) not in sys.path:
    sys.path.insert(0, str(_SCRIPT_DIR))

from yolo_txt_to_coco import convert_dataset  # noqa: E402


DEFAULT_REPO = "LibreYOLO/digits-t2eg6"


def _die(message: str, code: int = 1) -> int:
    print(message, file=sys.stderr)
    return code


def download_dataset(repo_id: str, dest: Path) -> Path:
    try:
        from huggingface_hub import snapshot_download
    except ImportError as exc:
        raise RuntimeError(
            "huggingface_hub is required. pip install huggingface_hub"
        ) from exc
    dest.mkdir(parents=True, exist_ok=True)
    snapshot_download(
        repo_id=repo_id,
        repo_type="dataset",
        local_dir=str(dest),
    )
    return dest


def write_notice(out: Path, repo_id: str) -> Path:
    text = f"""# Dataset NOTICE (training only)

Source: Hugging Face `{repo_id}`
Upstream: Roboflow 100 `digits-t2eg6`
URL: https://huggingface.co/datasets/{repo_id}
License: CC BY 4.0
Roboflow project: https://universe.roboflow.com/roboflow-100/digits-t2eg6/dataset/1

Attribution: Roboflow 100 / dataset-t2eg6 authors (see dataset card citation).
Derived COCO under `coco/` is a format conversion only; license of labels/images
remains CC BY 4.0.

When bundling a trained model into CogLog, cite this dataset in
`app_packages/infra/meter_reading/_mobile/assets/seven_segment/NOTICE.md`.
"""
    path = out / "NOTICE.md"
    path.write_text(text, encoding="utf-8")
    return path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--work-dir",
        type=Path,
        default=Path("datasets/digits_t2eg6"),
        help="Download + convert workspace (default: datasets/digits_t2eg6)",
    )
    parser.add_argument("--repo-id", default=DEFAULT_REPO)
    parser.add_argument(
        "--skip-download",
        action="store_true",
        help="Reuse an existing YOLO tree under --work-dir/yolo",
    )
    parser.add_argument(
        "--symlink-images",
        action="store_true",
        help="Symlink images into coco/ instead of copying",
    )
    args = parser.parse_args()

    work = args.work_dir.resolve()
    yolo_root = work / "yolo"
    coco_root = work / "coco"

    try:
        if args.skip_download:
            if not (yolo_root / "data.yaml").is_file() and not (
                yolo_root / "train" / "images"
            ).is_dir():
                return _die(f"Missing YOLO dataset under {yolo_root}")
        else:
            if yolo_root.exists():
                shutil.rmtree(yolo_root)
            download_dataset(args.repo_id, yolo_root)
        if coco_root.exists():
            shutil.rmtree(coco_root)
        summaries = convert_dataset(
            yolo_root,
            coco_root,
            [str(i) for i in range(10)],
            copy_images=not args.symlink_images,
        )
        notice = write_notice(work, args.repo_id)
    except (RuntimeError, FileNotFoundError, ValueError) as exc:
        return _die(str(exc))

    meta = {
        "repo_id": args.repo_id,
        "license": "CC-BY-4.0",
        "num_classes": 10,
        "yolo_root": str(yolo_root),
        "coco_root": str(coco_root),
        "notice": str(notice),
        "splits": summaries,
        "sscma_data_root": str(coco_root) + "/",
        "sscma_overrides": {
            "num_classes": 10,
            "width": 192,
            "height": 192,
            "train_ann": "train/_annotations.coco.json",
            "train_data": "train/",
            "val_ann": "valid/_annotations.coco.json",
            "val_data": "valid/",
        },
    }
    meta_path = work / "prepare_meta.json"
    meta_path.write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(meta, indent=2))
    print(f"Wrote {meta_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
