import 'package:riverpod/riverpod.dart';

import 'save_meter_capture_request.dart';
import 'save_meter_capture_result.dart';

/// メーター記録を運動履歴として保存する。
///
/// Example:
/// ```dart
/// usecase.execute(
///   SaveMeterCaptureRequest(
///     creationStartedAt: DateTime.timestamp(),
///     capturedAt: DateTime.timestamp(),
///     recordedAt: DateTime.timestamp(),
///     recordedAtManuallySet: false,
///     distanceKm: 1,
///     duration: const Duration(minutes: 1),
///     caloriesKcal: 1,
///     averageSpeedKmh: 1,
///     photoBytes: Uint8List(0),
///   ),
/// );
/// ```
abstract interface class SaveMeterCaptureUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<SaveMeterCaptureUsecase>(
    (ref) => throw UnimplementedError('SaveMeterCaptureUsecase.provider'),
  );

  /// [request] を検証し、運動履歴へ書き、ヘルスへ書く。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   SaveMeterCaptureRequest(
  ///     creationStartedAt: DateTime.timestamp(),
  ///     capturedAt: DateTime.timestamp(),
  ///     recordedAt: DateTime.timestamp(),
  ///     recordedAtManuallySet: false,
  ///     distanceKm: 1,
  ///     duration: const Duration(minutes: 1),
  ///     caloriesKcal: 1,
  ///     averageSpeedKmh: 1,
  ///     photoBytes: Uint8List(0),
  ///   ),
  /// );
  /// ```
  Future<SaveMeterCaptureResult> execute(SaveMeterCaptureRequest request);
}
