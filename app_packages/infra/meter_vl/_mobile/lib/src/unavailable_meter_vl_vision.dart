import 'dart:typed_data';

import 'package:infra_meter_vl/infra_meter_vl.dart';

/// ネイティブ未接続時のメーター VL 経路（常に利用不可）。
///
/// Example:
/// ```dart
/// const UnavailableMeterVlVision();
/// ```
final class UnavailableMeterVlVision implements MeterVlVision {
  /// 利用不可の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableMeterVlVision();
  /// ```
  const UnavailableMeterVlVision();

  /// 常に [MeterVlReadiness.unavailable]。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableMeterVlVision().readiness;
  /// ```
  @override
  Future<MeterVlReadiness> get readiness async => MeterVlReadiness.unavailable;

  /// 常に false。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableMeterVlVision().isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => false;

  /// 利用不可の固定スナップショット。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableMeterVlVision().availabilitySnapshot;
  /// ```
  @override
  Future<MeterVlAvailabilitySnapshot> get availabilitySnapshot async =>
      const MeterVlAvailabilitySnapshot(
        readiness: MeterVlReadiness.unavailable,
        status: 'unavailable',
        reason: 'notWired',
        message: 'Meter VL vision is unavailable',
      );

  /// 利用不可のため呼ばない想定。呼ばれたら失敗する。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableMeterVlVision().generateWithImage(
  ///   prompt: 'prompt',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    throw StateError('MeterVlVision is unavailable');
  }

  /// 診断でも利用不可として失敗する。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableMeterVlVision().diagnoseGenerateWithImage(
  ///   prompt: 'prompt',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    throw StateError('MeterVlVision is unavailable');
  }

  /// 利用不可として失敗するストリームを返す。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableMeterVlVision().prepareModel();
  /// ```
  @override
  Stream<double> prepareModel() {
    return Stream.error(StateError('MeterVlVision is unavailable'));
  }
}
