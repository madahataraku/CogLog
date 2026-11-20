import 'dart:io';

import 'package:test/test.dart';

/// Android LiteRT-LM の engine 配線が iOS / 文書と揃っていることを検査する。
///
/// Example:
/// ```bash
/// cd app_packages/infra/gemma_meter/_mobile
/// flutter test test/android_litert_mtp_constants_test.dart
/// ```
void main() {
  test('Android GemmaMeterPlugin uses GPU main/vision and MTP on', () {
    final file = File(
      [
        Directory.current.path,
        'android',
        'src',
        'main',
        'kotlin',
        'io',
        'github',
        'madahataraku',
        'coglog',
        'gemma_meter',
        'GemmaMeterPlugin.kt',
      ].join(Platform.pathSeparator),
    );
    expect(file.existsSync(), isTrue, reason: file.path);
    final source = file.readAsStringSync();

    expect(source, contains('backend = Backend.GPU()'));
    expect(source, contains('visionBackend = Backend.GPU()'));
    expect(source, contains('SpeculativeDecodingMode.ON'));
    expect(source, contains('ENGINE_STAMP_VALUE = "litert-mtp-gpu-v1"'));
    expect(source, contains('MIN_PLAUSIBLE_MODEL_BYTES'));
    expect(source, contains('readTotal < MIN_PLAUSIBLE_MODEL_BYTES'));
    expect(source, contains('"backend" to "gpu"'));
    expect(source, contains('"visionBackend" to "gpu"'));
    expect(source, isNot(contains('Backend.CPU()')));
  });
}
