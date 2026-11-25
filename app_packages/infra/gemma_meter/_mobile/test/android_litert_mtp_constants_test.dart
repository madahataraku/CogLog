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
  test('Android GemmaMeterPlugin uses GPU main, CPU vision, MTP off', () {
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
    expect(source, contains('visionBackend = Backend.CPU()'));
    expect(source, contains('SpeculativeDecodingMode.OFF'));
    expect(
      source,
      contains('ENGINE_STAMP_VALUE = "litert-lfm25-vl-int4-fixB-v1"'),
    );
    expect(source, isNot(contains('litert-mtp-gpu-v1')));
    expect(source, contains('ESTIMATED_MODEL_BYTES = 1_395_586_662L'));
    expect(source, isNot(contains('2_588_147_712L')));
    expect(source, contains('MIN_PLAUSIBLE_MODEL_BYTES'));
    expect(source, contains('readTotal < MIN_PLAUSIBLE_MODEL_BYTES'));
    expect(source, contains('"backend" to "gpu"'));
    expect(source, contains('"visionBackend" to "cpu"'));
    expect(source, contains('MODEL_DIR = "lfm_meter"'));
    expect(source, contains('LFM2.5-VL-1.6B_int4_fixB.litertlm'));
    expect(
      source,
      contains(
        'https://huggingface.co/litert-community/LFM2.5-VL-1.6B/resolve/main/LFM2.5-VL-1.6B_int4_fixB.litertlm',
      ),
    );
    expect(source, contains('LEGACY_MODEL_DIR = "gemma_meter"'));
    expect(source, contains('removeLegacyGemmaModelIfPresent'));
  });
}
