import 'dart:typed_data';

import 'package:infra_gemma_meter/infra_gemma_meter.dart';

/// テスト用の固定応答 Gemma 経路。
///
/// Example:
/// ```dart
/// FakeGemmaMeterVision(
///   response: 'DISTANCE_KM=1\nDURATION=0:10:00\nCALORIES_KCAL=10',
/// );
/// ```
final class FakeGemmaMeterVision implements GemmaMeterVision {
  /// [response] を返し、[readinessValue] と失敗フラグで振る舞いを切り替える。
  ///
  /// [availabilitySnapshot] を省略すると [readinessValue] から簡易スナップショットを作る。
  ///
  /// Example:
  /// ```dart
  /// FakeGemmaMeterVision(readinessValue: GemmaMeterReadiness.unavailable);
  /// ```
  FakeGemmaMeterVision({
    this.readinessValue = GemmaMeterReadiness.ready,
    this.response = 'DISTANCE_KM=1\nDURATION=0:10:00\nCALORIES_KCAL=10',
    this.throwOnGenerate = false,
    this.throwOnPrepare = false,
    this.prepareFailureKind,
    GemmaMeterAvailabilitySnapshot? availabilitySnapshot,
  }) : availabilitySnapshotValue =
           availabilitySnapshot ??
           GemmaMeterAvailabilitySnapshot(
             readiness: readinessValue,
             status: readinessValue.name,
             reason: readinessValue.name,
             message: 'fake',
           );

  /// [readiness] が返す値。
  final GemmaMeterReadiness readinessValue;

  /// [availabilitySnapshot] が返す値。
  final GemmaMeterAvailabilitySnapshot availabilitySnapshotValue;

  /// [generateWithImage] が返す文。
  final String response;

  /// true のとき [generateWithImage] が失敗する。
  final bool throwOnGenerate;

  /// true のとき [prepareModel] が失敗する。
  ///
  /// [prepareFailureKind] が非 null のときは型付き例外を優先する。
  final bool throwOnPrepare;

  /// 非 null のとき [prepareModel] が [GemmaMeterPrepareException] を投げる。
  final GemmaMeterPrepareFailureKind? prepareFailureKind;

  /// [generateWithImage] が呼ばれた回数。
  int generateWithImageCallCount = 0;

  /// [prepareModel] が呼ばれた回数。
  int prepareModelCallCount = 0;

  /// [readinessValue] を返す。
  ///
  /// Example:
  /// ```dart
  /// await gemma.readiness;
  /// ```
  @override
  Future<GemmaMeterReadiness> get readiness async => readinessValue;

  /// [readinessValue] が [GemmaMeterReadiness.ready] のとき true。
  ///
  /// Example:
  /// ```dart
  /// await gemma.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async =>
      readinessValue == GemmaMeterReadiness.ready;

  /// [availabilitySnapshotValue] を返す。
  ///
  /// Example:
  /// ```dart
  /// await gemma.availabilitySnapshot;
  /// ```
  @override
  Future<GemmaMeterAvailabilitySnapshot> get availabilitySnapshot async =>
      availabilitySnapshotValue;

  /// [response] を返すか、設定に応じて失敗する。
  ///
  /// Example:
  /// ```dart
  /// await gemma.generateWithImage(
  ///   prompt: 'prompt',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    generateWithImageCallCount++;
    if (throwOnGenerate) {
      throw StateError('fake generate failed');
    }
    return response;
  }

  /// [generateWithImage] と同じ経路で診断する。
  ///
  /// Example:
  /// ```dart
  /// await gemma.diagnoseGenerateWithImage(
  ///   prompt: 'prompt',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) => generateWithImage(prompt: prompt, imageBytes: imageBytes);

  /// 呼出回数を増やし、成功時は 1.0 を一度だけ出す。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in gemma.prepareModel()) {
  ///   progress;
  /// }
  /// ```
  @override
  Stream<double> prepareModel() async* {
    prepareModelCallCount++;
    final failureKind = prepareFailureKind;
    if (failureKind != null) {
      throw GemmaMeterPrepareException(failureKind);
    }
    if (throwOnPrepare) {
      throw StateError('fake prepare failed');
    }
    yield 1.0;
  }
}
