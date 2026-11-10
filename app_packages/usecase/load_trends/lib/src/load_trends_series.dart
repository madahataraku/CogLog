import 'package:domain_trends/domain_trends.dart';

/// 1 指標ぶんの点列と線分列。
///
/// Example:
/// ```dart
/// LoadTrendsSeries(
///   metric: TrendsMetricKind.exerciseCaloriesKcal,
///   points: const [],
///   segments: const [],
/// );
/// ```
final class LoadTrendsSeries {
  /// 指標・点・線分を持つ系列を作る。
  ///
  /// Example:
  /// ```dart
  /// const LoadTrendsSeries(
  ///   metric: TrendsMetricKind.bodyWeightKg,
  ///   points: [],
  ///   segments: [],
  /// );
  /// ```
  const LoadTrendsSeries({
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
