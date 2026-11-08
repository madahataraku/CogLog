import 'meter_reading_values.dart';

/// 走行距離・運動時間・消費カロリーが揃い、運動時間が 0 より大きいか。
///
/// Example:
/// ```dart
/// isCompleteMeterReadingCore(
///   const MeterReadingValues(
///     distanceKm: 1,
///     duration: Duration(minutes: 1),
///     caloriesKcal: 1,
///   ),
/// );
/// ```
bool isCompleteMeterReadingCore(MeterReadingValues values) =>
    values.distanceKm != null &&
    values.duration != null &&
    values.caloriesKcal != null &&
    values.duration! > Duration.zero;

/// 平均速度 (km/h) を距離と時間から求める。
///
/// [duration] が 0 以下なら null。
///
/// Example:
/// ```dart
/// calculateAverageSpeedKmh(distanceKm: 30, duration: const Duration(hours: 1));
/// ```
double? calculateAverageSpeedKmh({
  required double distanceKm,
  required Duration duration,
}) {
  if (duration <= Duration.zero) return null;
  final hours = duration.inMicroseconds / Duration.microsecondsPerHour;
  return distanceKm / hours;
}

/// マージ結果から初期の平均速度とパネル由来フラグを決める。
///
/// Example:
/// ```dart
/// resolveInitialAverageSpeed(
///   merged: const MeterReadingValues(
///     distanceKm: 1,
///     duration: Duration(hours: 1),
///   ),
/// );
/// ```
({double? speed, bool fromPanel}) resolveInitialAverageSpeed({
  required MeterReadingValues merged,
}) {
  if (merged.averageSpeedKmh != null) {
    return (speed: merged.averageSpeedKmh, fromPanel: true);
  }
  if (merged.distanceKm != null &&
      merged.duration != null &&
      merged.duration! > Duration.zero) {
    return (
      speed: calculateAverageSpeedKmh(
        distanceKm: merged.distanceKm!,
        duration: merged.duration!,
      ),
      fromPanel: false,
    );
  }
  return (speed: null, fromPanel: false);
}

/// 手打ち中の平均速度更新。
///
/// [averageSpeedClearedByUser] が true のときはパネル由来を捨てて再計算する。
///
/// Example:
/// ```dart
/// recalculateAverageSpeedIfNeeded(
///   distanceKm: 1,
///   duration: const Duration(hours: 1),
///   currentSpeed: 9,
///   averageSpeedFromPanel: true,
///   averageSpeedUserEdited: false,
///   averageSpeedClearedByUser: true,
/// );
/// ```
({double? speed, bool userEdited, bool fromPanel})
recalculateAverageSpeedIfNeeded({
  required double? distanceKm,
  required Duration? duration,
  required double? currentSpeed,
  required bool averageSpeedFromPanel,
  required bool averageSpeedUserEdited,
  required bool averageSpeedClearedByUser,
}) {
  if (averageSpeedClearedByUser) {
    final speed = (distanceKm != null && duration != null)
        ? calculateAverageSpeedKmh(distanceKm: distanceKm, duration: duration)
        : null;
    return (speed: speed, userEdited: false, fromPanel: false);
  }
  if (averageSpeedFromPanel || averageSpeedUserEdited) {
    return (
      speed: currentSpeed,
      userEdited: averageSpeedUserEdited,
      fromPanel: averageSpeedFromPanel,
    );
  }
  final speed = (distanceKm != null && duration != null)
      ? calculateAverageSpeedKmh(distanceKm: distanceKm, duration: duration)
      : null;
  return (speed: speed, userEdited: false, fromPanel: false);
}
