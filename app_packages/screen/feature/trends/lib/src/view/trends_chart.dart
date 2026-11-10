import 'package:domain_trends/domain_trends.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/entity/trends_visible_series.dart';
import 'trends_chart_painter.dart';

/// 推移グラフ領域。読込中は文言、それ以外は凡例と [CustomPaint]。
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

  /// X スロットのバケット列。
  final List<TrendsBucket> buckets;

  /// 描く系列。
  final List<TrendsVisibleSeries> series;

  /// 読込中文言または凡例付きグラフを返す。
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
    final seriesColors = [colors.primary, colors.mutedForeground];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (series.length > 1) _Legend(series: series, colors: seriesColors),
        Expanded(
          child: CustomPaint(
            painter: TrendsChartPainter(
              buckets: buckets,
              series: series,
              seriesColors: seriesColors,
              axisColor: colors.mutedForeground,
              labelStyle: context.theme.typography.body.sm.copyWith(
                color: colors.mutedForeground,
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

/// 複数系列の色と指標名を対応付ける。
final class _Legend extends StatelessWidget {
  /// [series] と [colors] を同じ順で並べる。
  ///
  /// Example:
  /// ```dart
  /// const _Legend(series: [], colors: []);
  /// ```
  const _Legend({required this.series, required this.colors});

  /// 凡例に出す系列。
  final List<TrendsVisibleSeries> series;

  /// 系列と同じ順の色。足りなければ循環する。
  final List<Color> colors;

  /// 色チップと指標名の行を返す。
  ///
  /// Example:
  /// ```dart
  /// const _Legend(series: [], colors: []).build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 4,
        children: [
          for (var i = 0; i < series.length; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColoredBox(
                  color: colors[i % colors.length],
                  child: const SizedBox(width: 12, height: 12),
                ),
                const SizedBox(width: 6),
                Text(_labelFor(series[i].metric), style: typography.body.sm),
              ],
            ),
        ],
      ),
    );
  }

  /// 指標に対応する表示文言を返す。
  ///
  /// Example:
  /// ```dart
  /// _labelFor(TrendsMetricKind.bodyWeightKg);
  /// ```
  String _labelFor(TrendsMetricKind metric) => switch (metric) {
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
}
