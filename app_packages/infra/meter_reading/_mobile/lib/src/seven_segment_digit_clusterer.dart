import 'dart:math' as math;

import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'seven_segment_digit_detection.dart';

/// 桁検出を数値トークンへまとめる。
abstract final class SevenSegmentDigitClusterer {
  /// 同一行の桁を左から連結し、広い隙間に `.` を入れる。
  ///
  /// Example:
  /// ```dart
  /// SevenSegmentDigitClusterer.clusterToTokens(const []);
  /// ```
  static List<MeterOcrToken> clusterToTokens(
    List<SevenSegmentDigitDetection> detections, {
    double rowThresholdFactor = 0.6,
    double gapDotFactor = 0.55,
  }) {
    if (detections.isEmpty) {
      return const [];
    }
    final heights = detections.map((d) => d.height).toList()..sort();
    final widths = detections.map((d) => d.width).toList()..sort();
    final medianH = heights[heights.length ~/ 2];
    final medianW = widths[widths.length ~/ 2];
    final sorted = [...detections]
      ..sort((a, b) => a.centerY.compareTo(b.centerY));
    final rows = <List<SevenSegmentDigitDetection>>[];
    for (final d in sorted) {
      if (rows.isEmpty) {
        rows.add([d]);
        continue;
      }
      final row = rows.last;
      final rowCy =
          row.map((e) => e.centerY).reduce((a, b) => a + b) / row.length;
      if ((d.centerY - rowCy).abs() <= rowThresholdFactor * medianH) {
        row.add(d);
      } else {
        rows.add([d]);
      }
    }
    final tokens = <MeterOcrToken>[];
    for (final row in rows) {
      row.sort((a, b) => a.centerX.compareTo(b.centerX));
      final buffer = StringBuffer();
      for (var i = 0; i < row.length; i++) {
        if (i > 0) {
          final gap = row[i].left - row[i - 1].right;
          if (gap > gapDotFactor * medianW) {
            buffer.write('.');
          }
        }
        buffer.write(row[i].digit);
      }
      final left = row.map((e) => e.left).reduce(math.min);
      final top = row.map((e) => e.top).reduce(math.min);
      final right = row.map((e) => e.right).reduce(math.max);
      final bottom = row.map((e) => e.bottom).reduce(math.max);
      tokens.add(
        MeterOcrToken(
          text: buffer.toString(),
          left: left,
          top: top,
          width: right - left,
          height: bottom - top,
        ),
      );
    }
    return tokens;
  }
}
