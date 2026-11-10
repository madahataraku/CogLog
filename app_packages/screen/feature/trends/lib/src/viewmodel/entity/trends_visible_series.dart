import 'package:domain_trends/domain_trends.dart';

/// グラフに描く 1 指標ぶんの点と線分。
///
/// Example:
/// ```dart
/// const TrendsVisibleSeries(
///   metric: TrendsMetricKind.exerciseCaloriesKcal,
///   points: [],
///   segments: [],
/// );
/// ```
final class TrendsVisibleSeries {
  /// 指標・点・線分を持つ系列を作る。
  ///
  /// Example:
  /// ```dart
  /// const TrendsVisibleSeries(
  ///   metric: TrendsMetricKind.bodyWeightKg,
  ///   points: [],
  ///   segments: [],
  /// );
  /// ```
  const TrendsVisibleSeries({
    required this.metric,
    required this.points,
    required this.segments,
  });

  /// この系列の指標。
  final TrendsMetricKind metric;

  /// バケット集約後の点。空バケットは含まない。
  final List<TrendsSeriesPoint> points;

  /// 隣接関係から決めた線分。
  final List<TrendsLineSegment> segments;
}
