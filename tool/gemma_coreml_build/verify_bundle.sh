#!/usr/bin/env bash
# Verify a finished Gemma 4 E2B Core ML bundle layout.
#
# Usage:
#   ./verify_bundle.sh /path/to/bundle
#   ./verify_bundle.sh /path/to/bundle --allow-missing-vision
set -euo pipefail

BUNDLE_DIR=""
ALLOW_MISSING_VISION=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --allow-missing-vision)
      ALLOW_MISSING_VISION=1
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
    *)
      if [[ -n "${BUNDLE_DIR}" ]]; then
        echo "Usage: $0 /path/to/bundle [--allow-missing-vision]" >&2
        exit 2
      fi
      BUNDLE_DIR="$1"
      shift
      ;;
  esac
done

if [[ -z "${BUNDLE_DIR}" || ! -d "${BUNDLE_DIR}" ]]; then
  echo "Usage: $0 /path/to/bundle [--allow-missing-vision]" >&2
  exit 2
fi

# Resolve to absolute for clearer logs.
BUNDLE_DIR="$(cd "${BUNDLE_DIR}" && pwd)"

status=0

exists_any() {
  local rel
  for rel in "$@"; do
    if [[ -e "${BUNDLE_DIR}/${rel}" ]]; then
      echo "OK: ${rel}"
      return 0
    fi
  done
  echo "MISSING (any of): $*" >&2
  return 1
}

forbid() {
  local path="$1"
  if [[ -e "${BUNDLE_DIR}/${path}" ]]; then
    echo "FORBIDDEN artifact present: ${path}" >&2
    return 1
  fi
  echo "OK absent: ${path}"
}

for i in 1 2 3 4; do
  exists_any "chunk${i}.mlmodelc" "chunk${i}.mlpackage" || status=1
  exists_any "prefill_chunk${i}.mlmodelc" "prefill_chunk${i}.mlpackage" || status=1
done

exists_any "model_config.json" || status=1
exists_any "hf_model/tokenizer.json" || status=1
exists_any "BUILD_INFO.json" || status=1

if [[ "${ALLOW_MISSING_VISION}" -eq 1 ]]; then
  echo "OK: vision optional (--allow-missing-vision)"
  # Stale vision must not linger in text-only mode.
  forbid "vision.ane.mlpackage" || status=1
  forbid "vision.ane.mlmodelc" || status=1
  forbid "vision.mlpackage" || status=1
  forbid "vision.mlmodelc" || status=1
else
  exists_any \
    "vision.ane.mlmodelc" \
    "vision.ane.mlpackage" \
    "vision.mlmodelc" \
    "vision.mlpackage" || status=1
fi

forbid "vision_video.mlpackage" || status=1
forbid "vision_video.mlmodelc" || status=1
forbid "audio.mlpackage" || status=1
forbid "audio.mlmodelc" || status=1

if [[ -e "${BUNDLE_DIR}/model.mlpackage" || -e "${BUNDLE_DIR}/model.mlmodelc" ]]; then
  echo "NOTE: monolithic model.* present (unexpected for chunk recipe)" >&2
fi

if [[ "${status}" -ne 0 ]]; then
  echo "Bundle verification FAILED: ${BUNDLE_DIR}" >&2
  exit 1
fi

echo "Bundle verification PASSED: ${BUNDLE_DIR}"
du -sh "${BUNDLE_DIR}" 2>/dev/null || true
