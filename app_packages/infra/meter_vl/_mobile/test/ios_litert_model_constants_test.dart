import 'dart:io';

import 'package:test/test.dart';

/// Native iOS LiteRT-LM 定数が Android / 文書と揃っていることを検査する。
///
/// Example:
/// ```bash
/// cd app_packages/infra/meter_vl/_mobile
/// flutter test test/ios_litert_model_constants_test.dart
/// ```
void main() {
  test('iOS MeterVlPlugin downloads litert-community LFM VL .litertlm', () {
    final file = File(
      [
        Directory.current.path,
        'ios',
        'infra_meter_vl_mobile',
        'Sources',
        'infra_meter_vl_mobile',
        'MeterVlPlugin.swift',
      ].join(Platform.pathSeparator),
    );
    expect(file.existsSync(), isTrue, reason: file.path);
    final source = file.readAsStringSync();

    expect(
      source,
      contains(
        'https://huggingface.co/litert-community/LFM2.5-VL-1.6B/resolve/main/LFM2.5-VL-1.6B_int4_fixB.litertlm',
      ),
    );
    expect(source, contains('LFM2.5-VL-1.6B_int4_fixB.litertlm'));
    expect(source, contains('1_395_586_662'));
    expect(source, isNot(contains('2_588_147_712')));
    expect(
      source,
      contains('minPlausibleModelBytes: Int64 = 100 * 1024 * 1024'),
    );
    expect(source, contains('legacyCoreMLFolderName = "gemma4-e2b"'));
    expect(source, contains('removeLegacyCoreMLModelIfPresent'));
    expect(source, contains('legacyGemmaLiteRtFolderName = "gemma_meter"'));
    expect(source, contains('removeLegacyGemmaLiteRtModelIfPresent'));
    expect(source, contains('estimatedModelBytes + 500_000_000'));
    expect(
      source,
      isNot(contains('estimatedModelBytes + estimatedModelBytes')),
    );
    expect(source, contains('backend: .cpu()'));
    expect(source, contains('visionBackend: .cpu()'));
    expect(source, contains('SpeculativeDecodingConfig(mode: .off)'));
    expect(
      source,
      contains('engineStampValue = "litert-lfm25-vl-int4-fixB-v1"'),
    );
    expect(source, isNot(contains('litert-mtp-gpu-v1')));
    expect(source, contains('try await created.initialize()'));
    expect(source, contains('try await active.createConversation()'));
    expect(source, isNot(contains('import CoreMLLLM')));
    expect(source, isNot(contains('mlboydaisuke')));
    expect(source, contains('modelFolderName = "lfm_meter"'));
  });
}
