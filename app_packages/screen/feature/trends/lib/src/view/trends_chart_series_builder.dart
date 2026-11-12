import 'package:domain_trends/domain_trends.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../strings.dart';
import '../viewmodel/entity/trends_visible_series.dart';

/// 左右どちらの Y 軸か。
enum TrendsChartAxisSide {
  /// 左（primary）。
  left,

  /// 右（opposed）。
  right,
}

/// 指標に対応する軸名・単位・左右。
///
/// Example:
/// ```dart
/// axisForTrendsMetric(TrendsMetricKind.exerciseCaloriesKcal);
/// ```
@internal
({String axisName, String unitLabel, TrendsChartAxisSide side})
axisForTrendsMetric(TrendsMetricKind metric) => switch (metric) {
  TrendsMetricKind.exerciseCaloriesKcal => (
    axisName: 'left',
    unitLabel: strings.screen_feature_trends_unit_kcal,
    side: TrendsChartAxisSide.left,
  ),
  TrendsMetricKind.exerciseDurationMinutes => (
    axisName: 'left',
    unitLabel: strings.screen_feature_trends_unit_minutes,
    side: TrendsChartAxisSide.left,
  ),
  TrendsMetricKind.exerciseDistanceKm => (
    axisName: 'right',
    unitLabel: strings.screen_feature_trends_unit_km,
    side: TrendsChartAxisSide.right,
  ),
  TrendsMetricKind.bodyWeightKg || TrendsMetricKind.bodyLeanMassKg => (
    axisName: 'right',
    unitLabel: strings.screen_feature_trends_unit_kg,
    side: TrendsChartAxisSide.right,
  ),
  TrendsMetricKind.bodyFatPercent => (
    axisName: 'right',
    unitLabel: strings.screen_feature_trends_unit_percent,
    side: TrendsChartAxisSide.right,
  ),
};

/// 代表日付を `yyyy-MM-dd` にする。
///
/// Example:
/// ```dart
/// formatTrendsChartDate(DateTime(2026, 11, 10));
/// ```
@internal
String formatTrendsChartDate(DateTime d) {
  final local = d.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

/// 指標の凡例・ツールチップ用ラベル。
///
/// Example:
/// ```dart
/// labelForTrendsMetric(TrendsMetricKind.bodyWeightKg);
/// ```
@internal
String labelForTrendsMetric(TrendsMetricKind metric) => switch (metric) {
  TrendsMetricKind.exerciseCaloriesKcal =>
    strings.screen_feature_trends_metric_calories,
  TrendsMetricKind.exerciseDurationMinutes =>
    strings.screen_feature_trends_metric_duration,
  TrendsMetricKind.exerciseDistanceKm =>
    strings.screen_feature_trends_metric_distance,
  TrendsMetricKind.bodyWeightKg =>
    strings.screen_feature_trends_metric_body_weight,
  TrendsMetricKind.bodyLeanMassKg =>
    strings.screen_feature_trends_metric_body_lean_mass,
  TrendsMetricKind.bodyFatPercent =>
    strings.screen_feature_trends_metric_body_fat,
};

/// [series] を Syncfusion 用の Cartesian 系列へ展開する。
///
/// 凡例は指標ごとの [ScatterSeries] のみ。線分の [LineSeries] は凡例非表示。
///
/// Example:
/// ```dart
/// buildTrendsCartesianSeries(
///   series: const [],
///   seriesColors: const [Color(0xFF000000)],
/// );
/// ```
@internal
List<CartesianSeries<TrendsSeriesPoint, DateTime>> buildTrendsCartesianSeries({
  required List<TrendsVisibleSeries> series,
  required List<Color> seriesColors,
}) {
  final out = <CartesianSeries<TrendsSeriesPoint, DateTime>>[];
  for (var i = 0; i < series.length; i++) {
    final visible = series[i];
    final color = seriesColors[i % seriesColors.length];
    final axis = axisForTrendsMetric(visible.metric);
    final name = labelForTrendsMetric(visible.metric);
    out.add(
      ScatterSeries<TrendsSeriesPoint, DateTime>(
        name: name,
        color: color,
        yAxisName: axis.axisName,
        isVisibleInLegend: true,
        dataSource: visible.points,
        xValueMapper: (p, _) => p.representativeDate,
        yValueMapper: (p, _) => p.value,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 8,
          width: 8,
        ),
      ),
    );
    for (final seg in visible.segments) {
      out.add(
        LineSeries<TrendsSeriesPoint, DateTime>(
          name: name,
          color: color,
          yAxisName: axis.axisName,
          isVisibleInLegend: false,
          enableTooltip: false,
          dataSource: [seg.from, seg.to],
          xValueMapper: (p, _) => p.representativeDate,
          yValueMapper: (p, _) => p.value,
          dashArray: seg.kind == TrendsLineKind.dashed
              ? const <double>[6, 4]
              : const <double>[],
        ),
      );
    }
  }
  return out;
}
