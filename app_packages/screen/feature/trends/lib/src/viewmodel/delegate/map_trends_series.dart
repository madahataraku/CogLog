import 'package:domain_trends/domain_trends.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';

import '../entity/trends_visible_series.dart';

/// usecase 系列を画面描画用へ写す。
///
/// Example:
/// ```dart
/// toVisibleTrendsSeries(
///   const LoadTrendsSeries(
///     metric: TrendsMetricKind.exerciseCaloriesKcal,
///     points: [],
///     segments: [],
///   ),
/// );
/// ```
TrendsVisibleSeries toVisibleTrendsSeries(LoadTrendsSeries series) =>
    TrendsVisibleSeries(
      metric: series.metric,
      points: series.points,
      segments: series.segments,
    );

/// 指標ごとの usecase 系列マップを描画用へ写す。
///
/// Example:
/// ```dart
/// mapTrendsSeries(const {});
/// ```
Map<TrendsMetricKind, TrendsVisibleSeries> mapTrendsSeries(
  Map<TrendsMetricKind, LoadTrendsSeries> input,
) => {for (final e in input.entries) e.key: toVisibleTrendsSeries(e.value)};
