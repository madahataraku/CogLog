import 'dart:typed_data';

import 'package:infra_gemma_meter/infra_gemma_meter.dart';

/// ネイティブ未接続時の Gemma 経路（常に利用不可）。
///
/// Example:
/// ```dart
/// const UnavailableGemmaMeterVision();
/// ```
final class UnavailableGemmaMeterVision implements GemmaMeterVision {
  /// 利用不可の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableGemmaMeterVision();
  /// ```
  const UnavailableGemmaMeterVision();

  /// 常に [GemmaMeterReadiness.unavailable]。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableGemmaMeterVision().readiness;
  /// ```
  @override
  Future<GemmaMeterReadiness> get readiness async =>
      GemmaMeterReadiness.unavailable;

  /// 常に false。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableGemmaMeterVision().isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => false;

  /// 利用不可の固定スナップショット。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableGemmaMeterVision().availabilitySnapshot;
  /// ```
  @override
  Future<GemmaMeterAvailabilitySnapshot> get availabilitySnapshot async =>
      const GemmaMeterAvailabilitySnapshot(
        readiness: GemmaMeterReadiness.unavailable,
        status: 'unavailable',
        reason: 'notWired',
        message: 'Gemma meter vision is unavailable',
      );

  /// 利用不可のため呼ばない想定。呼ばれたら失敗する。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableGemmaMeterVision().generateWithImage(
  ///   prompt: 'prompt',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    throw StateError('GemmaMeterVision is unavailable');
  }

  /// 診断でも利用不可として失敗する。
  ///
  /// Example:
  /// ```dart
  /// await const UnavailableGemmaMeterVision().diagnoseGenerateWithImage(
  ///   prompt: 'prompt',
  ///   imageBytes: Uint8List(0),
  /// );
  /// ```
  @override
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) async {
    throw StateError('GemmaMeterVision is unavailable');
  }

  /// 利用不可として失敗するストリームを返す。
  ///
  /// Example:
  /// ```dart
  /// const UnavailableGemmaMeterVision().prepareModel();
  /// ```
  @override
  Stream<double> prepareModel() {
    return Stream.error(StateError('GemmaMeterVision is unavailable'));
  }
}
