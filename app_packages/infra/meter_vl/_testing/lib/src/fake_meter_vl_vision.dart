import 'dart:async';
import 'dart:typed_data';

import 'package:infra_meter_vl/infra_meter_vl.dart';

/// テスト用の固定応答メーター VL 経路。
///
/// Example:
/// ```dart
/// FakeMeterVlVision(
///   response: 'DISTANCE_KM=1\nDURATION=0:10:00\nCALORIES_KCAL=10',
/// );
/// ```
final class FakeMeterVlVision implements MeterVlVision {
  /// [response] を返し、[readinessValue] と失敗フラグで振る舞いを切り替える。
  ///
  /// [availabilitySnapshot] を省略すると [readinessValue] から簡易スナップショットを作る。
  ///
  /// Example:
  /// ```dart
  /// FakeMeterVlVision(readinessValue: MeterVlReadiness.unavailable);
  /// ```
  FakeMeterVlVision({
    this.readinessValue = MeterVlReadiness.ready,
    this.response = 'DISTANCE_KM=1\nDURATION=0:10:00\nCALORIES_KCAL=10',
    this.throwOnGenerate = false,
    this.throwOnPrepare = false,
    this.throwOnAvailabilitySnapshot = false,
    this.hangOnPrepare = false,
    this.prepareFailureKind,
    MeterVlAvailabilitySnapshot? availabilitySnapshot,
  }) : availabilitySnapshotValue =
           availabilitySnapshot ??
           MeterVlAvailabilitySnapshot(
             readiness: readinessValue,
             status: readinessValue.name,
             reason: readinessValue.name,
             message: 'fake',
             backend: 'cpu',
             visionBackend: 'gpu',
           );

  /// [readiness] が返す値。
  final MeterVlReadiness readinessValue;

  /// [availabilitySnapshot] が返す値。
  final MeterVlAvailabilitySnapshot availabilitySnapshotValue;

  /// [generateWithImage] が返す文。
  final String response;

  /// true のとき [generateWithImage] が失敗する。
  final bool throwOnGenerate;

  /// true のとき [prepareModel] が失敗する。
  ///
  /// [prepareFailureKind] が非 null のときは型付き例外を優先する。
  final bool throwOnPrepare;

  /// true のとき [availabilitySnapshot] が失敗する。
  final bool throwOnAvailabilitySnapshot;

  /// true のとき [prepareModel] が完了しない（購読解除を検証する用）。
  final bool hangOnPrepare;

  /// 非 null のとき [prepareModel] が [MeterVlPrepareException] を投げる。
  final MeterVlPrepareFailureKind? prepareFailureKind;

  /// [generateWithImage] が呼ばれた回数。
  int generateWithImageCallCount = 0;

  /// [prepareModel] が呼ばれた回数。
  int prepareModelCallCount = 0;

  /// [hangOnPrepare] 時に購読が解除された回数。
  int prepareCancelCount = 0;

  /// [readinessValue] を返す。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.readiness;
  /// ```
  @override
  Future<MeterVlReadiness> get readiness async => readinessValue;

  /// [readinessValue] が [MeterVlReadiness.ready] のとき true。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async =>
      readinessValue == MeterVlReadiness.ready;

  /// [availabilitySnapshotValue] を返す。設定時は失敗する。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.availabilitySnapshot;
  /// ```
  @override
  Future<MeterVlAvailabilitySnapshot> get availabilitySnapshot async {
    if (throwOnAvailabilitySnapshot) {
      throw StateError('fake availabilitySnapshot failed');
    }
    return availabilitySnapshotValue;
  }

  /// [response] を返すか、設定に応じて失敗する。
  ///
  /// Example:
  /// ```dart
  /// await meterVl.generateWithImage(
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
  /// await meterVl.diagnoseGenerateWithImage(
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
  /// await for (final progress in meterVl.prepareModel()) {
  ///   progress;
  /// }
  /// ```
  @override
  Stream<double> prepareModel() {
    prepareModelCallCount++;
    final failureKind = prepareFailureKind;
    if (failureKind != null) {
      return Stream.error(MeterVlPrepareException(failureKind));
    }
    if (throwOnPrepare) {
      return Stream.error(StateError('fake prepare failed'));
    }
    if (hangOnPrepare) {
      final controller = StreamController<double>();
      controller.onCancel = () {
        prepareCancelCount++;
      };
      return controller.stream;
    }
    return Stream<double>.value(1.0);
  }
}
