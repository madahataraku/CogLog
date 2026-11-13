// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/seven_segment_digit_clusterer.dart';
import '../lib/src/seven_segment_digit_detection.dart';

/// 二進数で正確に表せる座標で閾値の等号を検証する。
///
/// Example:
/// ```dart
/// _digit(1, 0);
/// ```
SevenSegmentDigitDetection _digit(int digit, double left, {double top = 0}) =>
    SevenSegmentDigitDetection(
      digit: digit,
      score: 1,
      left: left,
      top: top,
      width: 0.0625,
      height: 0.125,
    );

void main() {
  test('入力順によらず上から下、左から右へ並べ元の入力を変更しない', () {
    final detections = [
      _digit(3, 0, top: 0.5),
      _digit(2, 0.0625),
      _digit(0, 0),
    ];
    final original = List<SevenSegmentDigitDetection>.of(detections);
    final tokens = SevenSegmentDigitClusterer.clusterToTokens(detections);
    expect(tokens.map((t) => t.text), ['02', '3']);
    expect(tokens.first.left, 0);
    expect(tokens.first.top, 0);
    expect(tokens.first.width, 0.125);
    expect(tokens.first.height, 0.125);
    expect(detections, orderedEquals(original));
  });

  for (final gap in [0.03125, 0.046875]) {
    test('小数点の閾値境界 gap=$gap', () {
      final tokens = SevenSegmentDigitClusterer.clusterToTokens([
        _digit(1, 0),
        _digit(2, 0.0625 + gap),
      ], gapDotFactor: 0.5);
      expect(tokens.single.text, gap == 0.03125 ? '12' : '1.2');
    });
  }

  for (final gap in [0.25, 0.265625]) {
    test('分割の閾値境界 gap=$gap', () {
      final tokens = SevenSegmentDigitClusterer.clusterToTokens([
        _digit(1, 0),
        _digit(2, 0.0625 + gap),
      ]);
      expect(tokens.map((t) => t.text), gap == 0.25 ? ['1.2'] : ['1', '2']);
    });
  }

  for (final top in [0.0625, 0.078125]) {
    test('同一行の閾値境界 top=$top', () {
      final tokens = SevenSegmentDigitClusterer.clusterToTokens([
        _digit(1, 0),
        _digit(2, 0.0625, top: top),
      ], rowThresholdFactor: 0.5);
      expect(tokens.map((t) => t.text), top == 0.0625 ? ['12'] : ['1', '2']);
    });
  }

  test('重なる桁の矩形を包含し小数点を挿入しない', () {
    final tokens = SevenSegmentDigitClusterer.clusterToTokens([
      _digit(1, 0),
      _digit(2, 0.03125, top: 0.015625),
    ]);
    expect(tokens.single.text, '12');
    expect(tokens.single.width, 0.09375);
    expect(tokens.single.height, 0.140625);
  });
}
