/// 走行距離・運動時間・平均速度・消費カロリーの読み取り値。
///
/// 欠ける項目は null。ビジネス判定は持たない。
///
/// Example:
/// ```dart
/// const MeterReadingValues(distanceKm: 1.0);
/// ```
final class MeterReadingValues {
  /// 欠落を許す読み取り値を作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterReadingValues(distanceKm: 1.0);
  /// ```
  const MeterReadingValues({
    this.distanceKm,
    this.duration,
    this.caloriesKcal,
    this.averageSpeedKmh,
  });

  /// 走行距離 km。
  final double? distanceKm;

  /// 運動時間。
  final Duration? duration;

  /// 消費カロリー kcal。
  final double? caloriesKcal;

  /// 平均速度 km/h。
  final double? averageSpeedKmh;
}
