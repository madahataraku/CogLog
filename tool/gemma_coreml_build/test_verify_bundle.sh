#!/usr/bin/env bash
# Lightweight checks for verify_bundle.sh (no Core ML conversion).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

fail() { echo "FAIL: $*" >&2; exit 1; }

make_base() {
  local root="$1"
  mkdir -p "${root}/hf_model"
  for i in 1 2 3 4; do
    mkdir -p "${root}/chunk${i}.mlmodelc" "${root}/prefill_chunk${i}.mlmodelc"
  done
  echo '{}' >"${root}/model_config.json"
  echo '{}' >"${root}/hf_model/tokenizer.json"
  echo '{}' >"${root}/BUILD_INFO.json"
}

# Full bundle with vision should pass.
FULL="${TMP}/full"
make_base "${FULL}"
mkdir -p "${FULL}/vision.ane.mlmodelc"
bash "${SCRIPT_DIR}/verify_bundle.sh" "${FULL}" >/dev/null \
  || fail "full bundle should pass"

# Missing vision should fail without flag.
NO_VISION="${TMP}/no_vision"
make_base "${NO_VISION}"
if bash "${SCRIPT_DIR}/verify_bundle.sh" "${NO_VISION}" >/dev/null 2>&1; then
  fail "missing vision should fail"
fi

# Text-only mode: missing vision OK, but stale vision forbidden.
TEXT="${TMP}/text"
make_base "${TEXT}"
bash "${SCRIPT_DIR}/verify_bundle.sh" "${TEXT}" --allow-missing-vision >/dev/null \
  || fail "text-only without vision should pass"
mkdir -p "${TEXT}/vision.mlmodelc"
if bash "${SCRIPT_DIR}/verify_bundle.sh" "${TEXT}" --allow-missing-vision >/dev/null 2>&1; then
  fail "text-only with stale vision should fail"
fi

# Forbidden video artifact.
BAD="${TMP}/bad"
make_base "${BAD}"
mkdir -p "${BAD}/vision.ane.mlmodelc" "${BAD}/vision_video.mlpackage"
if bash "${SCRIPT_DIR}/verify_bundle.sh" "${BAD}" >/dev/null 2>&1; then
  fail "vision_video should be forbidden"
fi

echo "test_verify_bundle.sh PASSED"
