#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../../../.." && pwd)"
OUT="$ROOT/app_packages/infra/oss_license_catalog/_impl/lib/gen/oss_licenses.dart"
cd "$ROOT/app_packages/infra/oss_license_catalog/_impl"
dart run dart_pubspec_licenses:generate \
  -p "$ROOT/app" \
  -o "$OUT" \
  -i app \
  -i app_runner
