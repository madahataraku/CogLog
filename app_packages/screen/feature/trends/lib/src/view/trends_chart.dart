import 'package:domain_trends/domain_trends.dart';
import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/entity/trends_visible_series.dart';
import 'trends_chart_painter.dart';

/// 推移グラフ領域。読込中は文言、それ以外は [CustomPaint]。
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

  /// 読込中文言またはグラフを返す。
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
    return CustomPaint(
      painter: TrendsChartPainter(
        buckets: buckets,
        series: series,
        seriesColors: [colors.primary, colors.mutedForeground],
        axisColor: colors.mutedForeground,
        labelStyle: context.theme.typography.body.sm.copyWith(
          color: colors.mutedForeground,
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}
