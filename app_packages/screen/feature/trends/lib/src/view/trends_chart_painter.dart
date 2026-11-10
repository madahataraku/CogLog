import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:domain_trends/domain_trends.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/entity/trends_visible_series.dart';

/// 推移グラフの点と実線／点線を描く。
///
/// Example:
/// ```dart
/// TrendsChartPainter(
///   buckets: const [],
///   series: const [],
///   seriesColors: const [Color(0xFF000000)],
///   axisColor: const Color(0xFF888888),
///   labelStyle: const TextStyle(fontSize: 10),
/// );
/// ```
final class TrendsChartPainter extends CustomPainter {
  /// バケット・系列・色・軸色・ラベルを持つ。
  ///
  /// Example:
  /// ```dart
  /// const TrendsChartPainter(
  ///   buckets: [],
  ///   series: [],
  ///   seriesColors: [Color(0xFF000000)],
  ///   axisColor: Color(0xFF888888),
  ///   labelStyle: TextStyle(fontSize: 10),
  /// );
  /// ```
  const TrendsChartPainter({
    required this.buckets,
    required this.series,
    required this.seriesColors,
    required this.axisColor,
    required this.labelStyle,
  });

  /// 上下の描画パディング。
  static const double paddingY = 16;

  /// 右の描画パディング。
  static const double paddingRight = 16;

  /// 左の描画パディング（縦軸ラベル幅）。
  static const double paddingLeft = 48;

  /// 縦軸目盛の目標本数（min/max を含む）。
  static const int yTickTargetCount = 5;

  /// 破線の実線長さ。
  static const double dashOn = 6;

  /// 破線の空き長さ。
  static const double dashOff = 4;

  /// X スロットに使うバケット列。
  final List<TrendsBucket> buckets;

  /// 描く系列（最大 2）。
  final List<TrendsVisibleSeries> series;

  /// 系列ごとの色。
  final List<Color> seriesColors;

  /// 軸とラベルの色。
  final Color axisColor;

  /// 軸ラベルの書式。
  final TextStyle labelStyle;

  /// 点・線・最小の軸ラベルを描く。
  ///
  /// Example:
  /// ```dart
  /// painter.paint(canvas, size);
  /// ```
  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTWH(
      paddingLeft,
      paddingY,
      math.max(0, size.width - paddingLeft - paddingRight),
      math.max(0, size.height - paddingY * 2),
    );
    if (plot.width <= 0 || plot.height <= 0) {
      return;
    }

    final values = <double>[
      for (final s in series)
        for (final p in s.points) p.value,
    ];
    final (:minY, :maxY) = _yRange(values);
    final ticks = values.length <= 1
        ? <double>[minY, if (minY != maxY) maxY]
        : _yTicks(minY, maxY, targetCount: yTickTargetCount);

    final indexByDate = <DateTime, int>{
      for (var i = 0; i < buckets.length; i++) buckets[i].representativeDate: i,
    };
    final slotCount = math.max(buckets.length, 1);

    Offset pointOffset(TrendsSeriesPoint point) {
      final index = indexByDate[point.representativeDate] ?? 0;
      final dx = slotCount == 1
          ? plot.left + plot.width / 2
          : plot.left + plot.width * (index / (slotCount - 1));
      final t = (maxY - minY) == 0 ? 0.0 : (point.value - minY) / (maxY - minY);
      final dy = plot.bottom - plot.height * t;
      return Offset(dx, dy);
    }

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axisPaint,
    );

    for (final y in ticks) {
      final t = (maxY - minY) == 0 ? 0.0 : (y - minY) / (maxY - minY);
      final dy = plot.bottom - plot.height * t;
      canvas.drawLine(
        Offset(plot.left, dy),
        Offset(plot.left + 4, dy),
        axisPaint,
      );
      _drawLabel(
        canvas,
        _formatY(y),
        Offset(plot.left - 4, dy),
        alignBottom: true,
        alignEnd: true,
      );
    }
    if (buckets.isNotEmpty) {
      _drawLabel(
        canvas,
        _formatX(buckets.first.representativeDate),
        Offset(plot.left, plot.bottom + 2),
        alignBottom: false,
        below: true,
      );
      if (buckets.length > 1) {
        _drawLabel(
          canvas,
          _formatX(buckets.last.representativeDate),
          Offset(plot.right, plot.bottom + 2),
          alignBottom: false,
          below: true,
          alignEnd: true,
        );
      }
    }

    for (var i = 0; i < series.length; i++) {
      final color = seriesColors[i % seriesColors.length];
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final pointPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      for (final segment in series[i].segments) {
        final from = pointOffset(segment.from);
        final to = pointOffset(segment.to);
        if (segment.kind == TrendsLineKind.solid) {
          canvas.drawLine(from, to, linePaint);
        } else {
          _drawDashedLine(canvas, from, to, linePaint);
        }
      }
      for (final point in series[i].points) {
        canvas.drawCircle(pointOffset(point), 3.5, pointPaint);
      }
    }
  }

  /// [minY]〜[maxY] を端点込みで約 [targetCount] 本に刻む。
  ///
  /// Example:
  /// ```dart
  /// _yTicks(0, 100, targetCount: 5);
  /// ```
  List<double> _yTicks(double minY, double maxY, {required int targetCount}) {
    if (minY == maxY) {
      return [minY];
    }
    final n = targetCount < 2 ? 2 : targetCount;
    return [for (var i = 0; i < n; i++) minY + (maxY - minY) * (i / (n - 1))];
  }

  /// 点の値から Y 軸の上下限を決める。
  ///
  /// Example:
  /// ```dart
  /// _yRange(const [100, 200]);
  /// ```
  ({double minY, double maxY}) _yRange(List<double> values) {
    if (values.isEmpty) {
      return (minY: 0, maxY: 1);
    }
    if (values.length == 1) {
      final v = values.single;
      final pad = math.max(v.abs() * 0.1, 1.0);
      return (minY: v - pad, maxY: v + pad);
    }
    var minY = values.reduce(math.min);
    var maxY = values.reduce(math.max);
    if (minY == maxY) {
      final pad = math.max(minY.abs() * 0.1, 1.0);
      minY -= pad;
      maxY += pad;
    }
    return (minY: minY, maxY: maxY);
  }

  /// [dashOn] / [dashOff] 間隔で [from] から [to] へ点線を描く。
  ///
  /// Example:
  /// ```dart
  /// _drawDashedLine(canvas, Offset.zero, const Offset(10, 0), paint);
  /// ```
  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    final total = (to - from).distance;
    if (total <= 0) {
      return;
    }
    final direction = (to - from) / total;
    var drawn = 0.0;
    var draw = true;
    while (drawn < total) {
      final remaining = total - drawn;
      final step = math.min(draw ? dashOn : dashOff, remaining);
      final start = from + direction * drawn;
      final end = from + direction * (drawn + step);
      if (draw) {
        canvas.drawLine(start, end, paint);
      }
      drawn += step;
      draw = !draw;
    }
  }

  /// 軸付近に短いラベルを置く。
  ///
  /// Example:
  /// ```dart
  /// _drawLabel(canvas, '1', Offset.zero, alignBottom: true);
  /// ```
  void _drawLabel(
    Canvas canvas,
    String text,
    Offset anchor, {
    required bool alignBottom,
    bool below = false,
    bool alignEnd = false,
  }) {
    final builder =
        ui.ParagraphBuilder(
            ui.ParagraphStyle(
              textAlign: alignEnd ? TextAlign.right : TextAlign.left,
            ),
          )
          ..pushStyle(
            ui.TextStyle(
              color: labelStyle.color ?? axisColor,
              fontSize: labelStyle.fontSize ?? 10,
            ),
          )
          ..addText(text);
    final paragraph = builder.build()
      ..layout(const ui.ParagraphConstraints(width: 80));
    final dx = alignEnd ? anchor.dx - paragraph.maxIntrinsicWidth : anchor.dx;
    final dy = below
        ? anchor.dy
        : alignBottom
        ? anchor.dy - paragraph.height
        : anchor.dy;
    canvas.drawParagraph(paragraph, Offset(dx, dy));
  }

  /// 代表日を短い月日表記にする。
  ///
  /// Example:
  /// ```dart
  /// _formatX(DateTime(2026, 11, 10));
  /// ```
  String _formatX(DateTime date) => '${date.month}/${date.day}';

  /// Y 値を整数または小数 1 桁で示す。
  ///
  /// Example:
  /// ```dart
  /// _formatY(12.5);
  /// ```
  String _formatY(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  /// 入力が変わったときだけ再描画する。
  ///
  /// Example:
  /// ```dart
  /// painter.shouldRepaint(oldDelegate);
  /// ```
  @override
  bool shouldRepaint(covariant TrendsChartPainter oldDelegate) {
    return oldDelegate.buckets != buckets ||
        oldDelegate.series != series ||
        oldDelegate.seriesColors != seriesColors ||
        oldDelegate.axisColor != axisColor ||
        oldDelegate.labelStyle != labelStyle;
  }
}
