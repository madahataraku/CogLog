import 'package:domain_trends/domain_trends.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../strings.dart';
import '../viewmodel/entity/trends_visible_series.dart';
import 'trends_chart_series_builder.dart';

/// 推移グラフ領域。読込中は文言、それ以外は Syncfusion チャート。
///
/// Example:
/// ```dart
/// TrendsChart(
///   loading: false,
///   buckets: const [],
///   series: const [],
/// );
/// ```
@internal
class TrendsChart extends StatelessWidget {
  /// 読込状態と描画データを受け取る。
  ///
  /// Example:
  /// ```dart
  /// const TrendsChart(
  ///   loading: true,
  ///   buckets: [],
  ///   series: [],
  /// );
  /// ```
  const TrendsChart({
    super.key,
    required this.loading,
    required this.buckets,
    required this.series,
  });

  /// 読込中ならプレースホルダ文言を出す。
  final bool loading;

  /// X スロットのバケット列（軸範囲の参考。系列点の日付が主）。
  final List<TrendsBucket> buckets;

  /// 描く系列。
  final List<TrendsVisibleSeries> series;

  /// 読込中文言または Syncfusion グラフを返す。
  ///
  /// Example:
  /// ```dart
  /// const TrendsChart(loading: true, buckets: [], series: []);
  /// ```
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Text(strings.screen_feature_trends_chart_placeholder),
      );
    }
    final colors = context.theme.colors;
    final seriesColors = <Color>[
      colors.primary,
      colors.mutedForeground,
      colors.foreground,
    ];
    final leftUnit = series.isEmpty
        ? ''
        : axisForTrendsMetric(series.first.metric).unitLabel;
    var rightUnit = '';
    for (final s in series) {
      final axis = axisForTrendsMetric(s.metric);
      if (axis.side == TrendsChartAxisSide.right) {
        rightUnit = axis.unitLabel;
        break;
      }
    }
    final xAxis = buckets.isEmpty
        ? const DateTimeAxis()
        : DateTimeAxis(
            minimum: buckets.first.startInclusive,
            maximum: buckets.last.endExclusive,
          );
    return SfCartesianChart(
      primaryXAxis: xAxis,
      primaryYAxis: NumericAxis(
        name: 'left',
        title: AxisTitle(text: leftUnit),
      ),
      axes: [
        NumericAxis(
          name: 'right',
          opposedPosition: true,
          title: AxisTitle(text: rightUnit),
        ),
      ],
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.top,
        toggleSeriesVisibility: false,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
        builder:
            (
              dynamic data,
              dynamic point,
              dynamic seriesObj,
              int pointIndex,
              int seriesIndex,
            ) {
              final p = data as TrendsSeriesPoint;
              final title = seriesObj is CartesianSeries
                  ? (seriesObj.name ?? '')
                  : '';
              final metric = metricForTrendsChartSeriesName(
                seriesObj is CartesianSeries ? seriesObj.name : null,
              );
              return Container(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '$title\n${formatTrendsChartDate(p.representativeDate)}: ${formatTrendsChartValue(p.value, metric: metric)}',
                ),
              );
            },
      ),
      series: buildTrendsCartesianSeries(
        series: series,
        seriesColors: seriesColors,
      ),
    );
  }
}
