import 'dart:math' as math;

import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'seven_segment_digit_detection.dart';

/// 桁検出を数値トークンへまとめる。
abstract final class SevenSegmentDigitClusterer {
  /// 同一行の桁を左から連結する。
  ///
  /// 隙間が [gapDotFactor]×中央幅を超えると `.` を挿入し、
  /// [gapSplitFactor]×中央幅を超えると別トークンへ分割する。
  ///
  /// Example:
  /// ```dart
  /// SevenSegmentDigitClusterer.clusterToTokens(const []);
  /// ```
  static List<MeterOcrToken> clusterToTokens(
    List<SevenSegmentDigitDetection> detections, {
    double rowThresholdFactor = 0.6,
    double gapDotFactor = 0.55,
    double gapSplitFactor = 4.0,
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
    final splitGap = gapSplitFactor * medianW;
    final dotGap = gapDotFactor * medianW;
    for (final row in rows) {
      row.sort((a, b) => a.centerX.compareTo(b.centerX));
      var groupStart = 0;
      for (var i = 0; i <= row.length; i++) {
        final atEnd = i == row.length;
        final shouldSplit =
            !atEnd && i > 0 && (row[i].left - row[i - 1].right) > splitGap;
        if (!atEnd && !shouldSplit) {
          continue;
        }
        final group = row.sublist(groupStart, i == row.length ? row.length : i);
        groupStart = i;
        if (group.isEmpty) {
          continue;
        }
        final buffer = StringBuffer();
        for (var j = 0; j < group.length; j++) {
          if (j > 0) {
            final gap = group[j].left - group[j - 1].right;
            if (gap > dotGap) {
              buffer.write('.');
            }
          }
          buffer.write(group[j].digit);
        }
        final left = group.map((e) => e.left).reduce(math.min);
        final top = group.map((e) => e.top).reduce(math.min);
        final right = group.map((e) => e.right).reduce(math.max);
        final bottom = group.map((e) => e.bottom).reduce(math.max);
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
    }
    return tokens;
  }
}
