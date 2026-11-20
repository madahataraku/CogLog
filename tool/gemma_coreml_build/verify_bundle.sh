#!/usr/bin/env bash
# Verify a finished Gemma 4 E2B Core ML bundle layout.
set -euo pipefail

BUNDLE_DIR="${1:-}"
if [[ -z "${BUNDLE_DIR}" || ! -d "${BUNDLE_DIR}" ]]; then
  echo "Usage: $0 /path/to/bundle" >&2
  exit 2
fi

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

exists_any \
  "vision.ane.mlmodelc" \
  "vision.ane.mlpackage" \
  "vision.mlmodelc" \
  "vision.mlpackage" || status=1

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
