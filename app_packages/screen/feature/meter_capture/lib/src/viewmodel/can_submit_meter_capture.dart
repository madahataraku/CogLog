/// 登録可能か。全項目入力済み・運動時間 > 0・距離・速度・カロリーが非負。
///
/// Example:
/// ```dart
/// canSubmitMeterCapture(
///   distanceKm: 1,
///   duration: const Duration(minutes: 1),
///   averageSpeedKmh: 1,
///   caloriesKcal: 1,
/// );
/// ```
bool canSubmitMeterCapture({
  required double? distanceKm,
  required Duration? duration,
  required double? averageSpeedKmh,
  required double? caloriesKcal,
}) {
  if (distanceKm == null ||
      duration == null ||
      averageSpeedKmh == null ||
      caloriesKcal == null) {
    return false;
  }
  if (duration <= Duration.zero) return false;
  if (distanceKm < 0 || averageSpeedKmh < 0 || caloriesKcal < 0) {
    return false;
  }
  return true;
}
