import 'dart:async';
import 'dart:typed_data';

import 'package:infra_on_device_llm/infra_on_device_llm.dart';

/// テスト用の固定応答 LLM。
///
/// Example:
/// ```dart
/// FakeOnDeviceLlm(response: '定型ではない助言');
/// ```
final class FakeOnDeviceLlm implements OnDeviceLlm {
  /// [response] を返し、[readiness] で準備状態を切り替える。
  ///
  /// [available] のみ渡したときは ready / unavailable に写す。
  ///
  /// Example:
  /// ```dart
  /// FakeOnDeviceLlm(available: false);
  /// ```
  FakeOnDeviceLlm({
    bool available = true,
    OnDeviceLlmReadiness? readiness,
    OnDeviceLlmAvailabilitySnapshot? availabilitySnapshot,
    this.response = 'fake advice',
    this.supportsVisionValue = false,
    this.throwOnGenerate = false,
    this.throwOnIsAvailable = false,
    this.throwOnReadiness = false,
    this.throwOnAvailabilitySnapshot = false,
    this.throwOnPrepareModel = false,
    this.hangOnGenerate = false,
  }) : readinessValue =
           readiness ??
           (available
               ? OnDeviceLlmReadiness.ready
               : OnDeviceLlmReadiness.unavailable),
       availabilitySnapshotValue =
           availabilitySnapshot ??
           OnDeviceLlmAvailabilitySnapshot(
             readiness:
                 readiness ??
                 (available
                     ? OnDeviceLlmReadiness.ready
                     : OnDeviceLlmReadiness.unavailable),
             status: available ? 'available' : 'unavailable',
             reason: available ? 'ready' : 'deviceNotEligible',
             message: available ? 'Fake ready' : 'Fake unavailable',
           );

  /// [readiness] が返す値。
  final OnDeviceLlmReadiness readinessValue;

  /// [availabilitySnapshot] が返す値。
  final OnDeviceLlmAvailabilitySnapshot availabilitySnapshotValue;

  /// [generate] が返す文。
  final String response;

  /// [supportsVision] が返す値。
  final bool supportsVisionValue;

  /// true のとき [generate] が失敗する。
  final bool throwOnGenerate;

  /// true のとき [isAvailable] が失敗する。
  final bool throwOnIsAvailable;

  /// true のとき [readiness] が失敗する。
  final bool throwOnReadiness;

  /// true のとき [availabilitySnapshot] が失敗する。
  final bool throwOnAvailabilitySnapshot;

  /// true のとき [prepareModel] が失敗する。
  final bool throwOnPrepareModel;

  /// true のとき [generate] / [generateWithImage] が完了しない。
  final bool hangOnGenerate;

  /// [generate] が呼ばれた回数。
  int generateCallCount = 0;

  /// [generateWithImage] が呼ばれた回数。
  int generateWithImageCallCount = 0;

  /// [prepareModel] が呼ばれた回数。
  int prepareModelCallCount = 0;

  /// 最後に渡されたプロンプト。
  String? lastPrompt;

  /// 最後に [generateWithImage] へ渡された画像バイト。
  Uint8List? lastImageBytes;

  /// [readinessValue] を返す。
  ///
  /// Example:
  /// ```dart
  /// await llm.readiness;
  /// ```
  @override
  Future<OnDeviceLlmReadiness> get readiness async {
    if (throwOnReadiness) {
      throw StateError('FakeOnDeviceLlm readiness failed');
    }
    return readinessValue;
  }

  /// [readinessValue] が ready のとき true。
  ///
  /// Example:
  /// ```dart
  /// await llm.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async {
    if (throwOnIsAvailable) {
      throw StateError('FakeOnDeviceLlm isAvailable failed');
    }
    return readinessValue == OnDeviceLlmReadiness.ready;
  }

  /// [supportsVisionValue] を返す。
  ///
  /// Example:
  /// ```dart
  /// await llm.supportsVision;
  /// ```
  @override
  Future<bool> get supportsVision async => supportsVisionValue;

  /// [availabilitySnapshotValue] を返す。
  ///
  /// Example:
  /// ```dart
  /// await llm.availabilitySnapshot;
  /// ```
  @override
  Future<OnDeviceLlmAvailabilitySnapshot> get availabilitySnapshot async {
    if (throwOnAvailabilitySnapshot) {
      throw StateError('FakeOnDeviceLlm availabilitySnapshot failed');
    }
    return availabilitySnapshotValue;
  }

  /// [response] を返すか、設定に応じて失敗する。
  ///
  /// Example:
  /// ```dart
  /// await llm.generate('prompt');
  /// ```
  @override
  Future<String> generate(String prompt) async {
    generateCallCount += 1;
    lastPrompt = prompt;
    if (throwOnGenerate) {
      throw StateError('FakeOnDeviceLlm generate failed');
    }
    if (hangOnGenerate) {
      return Completer<String>().future;
    }
    return response;
  }

  /// [generate] と同じ失敗・待機設定で [response] を返す。
  ///
  /// Example:
  /// ```dart
  /// await llm.generateWithImage(
  ///   prompt: 'prompt',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    generateWithImageCallCount += 1;
    lastPrompt = prompt;
    lastImageBytes = imageBytes;
    if (throwOnGenerate) {
      throw StateError('FakeOnDeviceLlm generate failed');
    }
    if (hangOnGenerate) {
      return Completer<String>().future;
    }
    return response;
  }

  /// [generate] と同じ経路で診断する。
  ///
  /// Example:
  /// ```dart
  /// await llm.diagnoseGenerate('prompt');
  /// ```
  @override
  Future<String> diagnoseGenerate(String prompt) => generate(prompt);

  /// 呼出回数を増やし、設定に応じて失敗する。
  ///
  /// Example:
  /// ```dart
  /// await llm.prepareModel();
  /// ```
  @override
  Future<void> prepareModel() async {
    prepareModelCallCount += 1;
    if (throwOnPrepareModel) {
      throw StateError('FakeOnDeviceLlm prepareModel failed');
    }
  }
}
