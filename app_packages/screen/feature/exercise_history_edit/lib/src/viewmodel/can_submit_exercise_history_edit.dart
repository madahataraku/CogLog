import 'package:meta/meta.dart';

/// 編集保存可能か。全項目入力済み・運動時間 > 0・距離・速度・カロリーが非負有限。
///
/// Example:
/// ```dart
/// canSubmitExerciseHistoryEdit(
///   distanceKm: 1,
///   duration: const Duration(minutes: 1),
///   averageSpeedKmh: 1,
///   caloriesKcal: 1,
///   recordedAt: DateTime.timestamp(),
///   creationStartedAt: DateTime.timestamp(),
///   capturedAt: DateTime.timestamp(),
/// );
/// ```
@internal
bool canSubmitExerciseHistoryEdit({
  required double? distanceKm,
  required Duration? duration,
  required double? averageSpeedKmh,
  required double? caloriesKcal,
  required DateTime? recordedAt,
  required DateTime? creationStartedAt,
  required DateTime? capturedAt,
}) {
  if (distanceKm == null ||
      duration == null ||
      averageSpeedKmh == null ||
      caloriesKcal == null ||
      recordedAt == null ||
      creationStartedAt == null ||
      capturedAt == null) {
    return false;
  }
  if (duration <= Duration.zero) return false;
  if (!distanceKm.isFinite ||
      !averageSpeedKmh.isFinite ||
      !caloriesKcal.isFinite) {
    return false;
  }
  if (distanceKm < 0 || averageSpeedKmh < 0 || caloriesKcal < 0) {
    return false;
  }
  return true;
}
