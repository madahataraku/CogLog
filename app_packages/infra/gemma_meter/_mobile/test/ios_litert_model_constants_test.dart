import 'dart:io';

import 'package:test/test.dart';

/// Native iOS LiteRT-LM 定数が Android / 文書と揃っていることを検査する。
///
/// Example:
/// ```bash
/// cd app_packages/infra/gemma_meter/_mobile
/// flutter test test/ios_litert_model_constants_test.dart
/// ```
void main() {
  test(
    'iOS GemmaMeterPlugin downloads the same litert-community E2B .litertlm',
    () {
      final file = File(
        [
          Directory.current.path,
          'ios',
          'infra_gemma_meter_mobile',
          'Sources',
          'infra_gemma_meter_mobile',
          'GemmaMeterPlugin.swift',
        ].join(Platform.pathSeparator),
      );
      expect(file.existsSync(), isTrue, reason: file.path);
      final source = file.readAsStringSync();

      expect(
        source,
        contains(
          'https://huggingface.co/litert-community/gemma-4-E2B-it-litert-lm/resolve/main/gemma-4-E2B-it.litertlm',
        ),
      );
      expect(source, contains('gemma-4-E2B-it.litertlm'));
      expect(source, contains('2_588_147_712'));
      expect(
        source,
        contains('minPlausibleModelBytes: Int64 = 100 * 1024 * 1024'),
      );
      expect(source, contains('legacyCoreMLFolderName = "gemma4-e2b"'));
      expect(source, contains('removeLegacyCoreMLModelIfPresent'));
      expect(source, contains('estimatedModelBytes + 500_000_000'));
      expect(
        source,
        isNot(contains('estimatedModelBytes + estimatedModelBytes')),
      );
      expect(source, contains('backend: .gpu'));
      expect(source, contains('visionBackend: .gpu'));
      expect(source, contains('SpeculativeDecodingConfig(mode: .on)'));
      expect(source, contains('engineStampValue = "litert-mtp-gpu-v1"'));
      expect(source, contains('try await created.initialize()'));
      expect(source, contains('try await active.createConversation()'));
      expect(source, isNot(contains('import CoreMLLLM')));
      expect(source, isNot(contains('mlboydaisuke')));
    },
  );
}
