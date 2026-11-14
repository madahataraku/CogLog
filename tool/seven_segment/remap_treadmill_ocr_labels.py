#!/usr/bin/env python3
"""Remap gabolauro treadmill-ocr YOLO classes to CogLog digit 0–9.

Treadmill OCR uses dual-font digit names plus symbols, e.g.::

    zero_ zero. one_ one. ... nine_ nine. colon_ colon. dash. dot.

CogLog's bundled Swift-YOLO contract is **10 digit classes** (0–9).
This script:

- maps ``zero_``/``zero.`` → 0 … ``nine_``/``nine.`` → 9
- drops symbol classes (colon / dash / dot); the app inserts ``.`` by gap

**License gate:** only run after the Roboflow Universe project Cite section
shows a permissive license (e.g. CC BY 4.0). If the license field is missing,
the author reserves all rights — do not use for redistribution.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


DIGIT_NAME_TO_ID = {
    "zero": 0,
    "one": 1,
    "two": 2,
    "three": 3,
    "four": 4,
    "five": 5,
    "six": 6,
    "seven": 7,
    "eight": 8,
    "nine": 9,
}

# Default Roboflow class order observed on treadmill-ocr-gqnwo (24 classes).
DEFAULT_NAMES = [
    "colon_",
    "colon.",
    "dash.",
    "dot.",
    "eight_",
    "eight.",
    "five_",
    "five.",
    "four_",
    "four.",
    "nine_",
    "nine.",
    "one_",
    "one.",
    "seven_",
    "seven.",
    "six_",
    "six.",
    "three_",
    "three.",
    "two_",
    "two.",
    "zero_",
    "zero.",
]


def _die(message: str, code: int = 1) -> int:
    print(message, file=sys.stderr)
    return code


def parse_names_file(path: Path) -> list[str]:
    text = path.read_text(encoding="utf-8")
    names: list[str] = []
    for line in text.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        # data.yaml style: "- name" or "0: name"
        m = re.match(r"^-\s*['\"]?(.+?)['\"]?\s*$", line)
        if m:
            names.append(m.group(1))
            continue
        m = re.match(r"^\d+\s*:\s*['\"]?(.+?)['\"]?\s*$", line)
        if m:
            names.append(m.group(1))
            continue
        if "," not in line and ":" not in line:
            names.append(line)
    if not names:
        raise ValueError(f"No class names parsed from {path}")
    return names


def class_id_to_digit(class_id: int, names: list[str]) -> int | None:
    if class_id < 0 or class_id >= len(names):
        raise ValueError(f"class_id {class_id} out of range for {len(names)} names")
    raw = names[class_id].strip().lower()
    stem = re.sub(r"[_\.]+$", "", raw)
    stem = stem.replace("_", "").replace(".", "")
    # names like zero_ / zero. → zero
    for key, digit in DIGIT_NAME_TO_ID.items():
        if stem == key or raw.startswith(key):
            return digit
    return None


def remap_label_file(src: Path, dest: Path, names: list[str]) -> tuple[int, int]:
    kept = 0
    dropped = 0
    lines_out: list[str] = []
    if not src.is_file():
        dest.write_text("", encoding="utf-8")
        return 0, 0
    for line in src.read_text(encoding="utf-8").splitlines():
        text = line.strip()
        if not text:
            continue
        parts = text.split()
        if len(parts) != 5:
            raise ValueError(f"Bad YOLO line in {src}: {text!r}")
        class_id = int(float(parts[0]))
        digit = class_id_to_digit(class_id, names)
        if digit is None:
            dropped += 1
            continue
        lines_out.append(
            f"{digit} {parts[1]} {parts[2]} {parts[3]} {parts[4]}"
        )
        kept += 1
    dest.parent.mkdir(parents=True, exist_ok=True)
    dest.write_text("\n".join(lines_out) + ("\n" if lines_out else ""), encoding="utf-8")
    return kept, dropped


def remap_tree(root: Path, out: Path, names: list[str]) -> dict[str, int]:
    totals = {"kept": 0, "dropped": 0, "files": 0}
    for split in ("train", "valid", "val", "test"):
        labels = root / split / "labels"
        if not labels.is_dir():
            continue
        out_split = "valid" if split == "val" else split
        out_labels = out / out_split / "labels"
        out_images = out / out_split / "images"
        images = root / split / "images"
        out_labels.mkdir(parents=True, exist_ok=True)
        out_images.mkdir(parents=True, exist_ok=True)
        for label_path in sorted(labels.glob("*.txt")):
            kept, dropped = remap_label_file(
                label_path, out_labels / label_path.name, names
            )
            totals["kept"] += kept
            totals["dropped"] += dropped
            totals["files"] += 1
            stem = label_path.stem
            if images.is_dir():
                for img in images.glob(stem + ".*"):
                    dest = out_images / img.name
                    if not dest.exists():
                        dest.symlink_to(img.resolve())
    return totals


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, required=True, help="YOLO dataset root")
    parser.add_argument("--out", type=Path, required=True, help="Remapped YOLO root")
    parser.add_argument(
        "--names-file",
        type=Path,
        default=None,
        help="Optional file listing class names in id order",
    )
    parser.add_argument(
        "--i-confirmed-permissive-license",
        action="store_true",
        help="Required: confirm Universe Cite license is permissive (e.g. CC BY)",
    )
    args = parser.parse_args()
    if not args.i_confirmed_permissive_license:
        return _die(
            "Refusing to remap: pass --i-confirmed-permissive-license after "
            "verifying the Roboflow Cite license is permissive."
        )
    try:
        names = (
            parse_names_file(args.names_file)
            if args.names_file
            else list(DEFAULT_NAMES)
        )
        totals = remap_tree(args.root.resolve(), args.out.resolve(), names)
    except (ValueError, FileNotFoundError) as exc:
        return _die(str(exc))
    print(
        f"Remapped files={totals['files']} kept={totals['kept']} "
        f"dropped_symbols={totals['dropped']} -> {args.out}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
