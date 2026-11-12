import 'meter_reading_message_kind.dart';
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

/// 読み取り値から画面メッセージ区分を決める。
///
/// Example:
/// ```dart
/// classifyMeterReadingMessages(const MeterReadingValues());
/// ```
MeterReadingMessageKind classifyMeterReadingMessages(
  MeterReadingValues values,
) {
  if (isCompleteMeterReadingCore(values)) {
    return MeterReadingMessageKind.complete;
  }
  final anyCore =
      values.distanceKm != null ||
      values.duration != null ||
      values.caloriesKcal != null;
  return anyCore
      ? MeterReadingMessageKind.incomplete
      : MeterReadingMessageKind.empty;
}

/// 手打ち案内を出すべき読み取り結果か。
///
/// [classifyMeterReadingMessages] が [MeterReadingMessageKind.complete]
/// 以外のとき true。
///
/// Example:
/// ```dart
/// needsMeterHandEntryGuidance(const MeterReadingValues());
/// ```
bool needsMeterHandEntryGuidance(MeterReadingValues values) =>
    classifyMeterReadingMessages(values) != MeterReadingMessageKind.complete;

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

/// マージ結果から初期の平均速度を距離÷時間で求める。
///
/// パネルの平均速度は使わない。[fromPanel] は常に false。
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

/// 距離と時間から平均速度を再計算する。
///
/// どちらかが無いときは null。
///
/// Example:
/// ```dart
/// recalculateAverageSpeedIfNeeded(
///   distanceKm: 1,
///   duration: const Duration(hours: 1),
/// );
/// ```
double? recalculateAverageSpeedIfNeeded({
  required double? distanceKm,
  required Duration? duration,
}) {
  if (distanceKm == null || duration == null) return null;
  return calculateAverageSpeedKmh(distanceKm: distanceKm, duration: duration);
}
