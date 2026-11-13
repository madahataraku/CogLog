import 'meter_reading_values.dart';

/// 複数エンジンの読み取り値を後勝ちで束ねる。
///
/// Example:
/// ```dart
/// MeterReadingMerger.merge(
///   const MeterReadingValues(distanceKm: 1),
///   const MeterReadingValues(distanceKm: 2, caloriesKcal: 3),
/// );
/// ```
abstract final class MeterReadingMerger {
  /// [next] の非 null フィールドで [previous] を上書きする。
  ///
  /// Example:
  /// ```dart
  /// MeterReadingMerger.merge(
  ///   const MeterReadingValues(distanceKm: 1),
  ///   const MeterReadingValues(distanceKm: 2, caloriesKcal: 3),
  /// );
  /// ```
  static MeterReadingValues merge(
    MeterReadingValues previous,
    MeterReadingValues next,
  ) {
    return MeterReadingValues(
      distanceKm: next.distanceKm ?? previous.distanceKm,
      duration: next.duration ?? previous.duration,
      caloriesKcal: next.caloriesKcal ?? previous.caloriesKcal,
      averageSpeedKmh: next.averageSpeedKmh ?? previous.averageSpeedKmh,
    );
  }

  /// [preferred] の非 null を残し、欠落だけ [fallback] で埋める。
  ///
  /// 空間 OCR の汎用結果を [preferred]、七セグ補完を [fallback] に渡す。
  ///
  /// Example:
  /// ```dart
  /// MeterReadingMerger.preferFirst(
  ///   const MeterReadingValues(distanceKm: 1),
  ///   const MeterReadingValues(distanceKm: 9, caloriesKcal: 3),
  /// );
  /// ```
  static MeterReadingValues preferFirst(
    MeterReadingValues preferred,
    MeterReadingValues fallback,
  ) {
    return MeterReadingValues(
      distanceKm: preferred.distanceKm ?? fallback.distanceKm,
      duration: preferred.duration ?? fallback.duration,
      caloriesKcal: preferred.caloriesKcal ?? fallback.caloriesKcal,
      averageSpeedKmh: preferred.averageSpeedKmh ?? fallback.averageSpeedKmh,
    );
  }
}
