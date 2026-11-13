// ignore_for_file: avoid_relative_lib_imports

import 'package:test/test.dart';

import '../lib/src/seven_segment_digit_clusterer.dart';
import '../lib/src/seven_segment_digit_detection.dart';
import '../lib/src/seven_segment_letterbox_meta.dart';
import '../lib/src/seven_segment_yolo_postprocess.dart';

void main() {
  const letterbox = SevenSegmentLetterboxMeta(
    scale: 1,
    padX: 0,
    padY: 0,
    srcWidth: 192,
    srcHeight: 192,
  );

  test('score 0.9 の行は digit 1 を検出する', () {
    final row = List<double>.filled(15, 0);
    row[0] = 96;
    row[1] = 96;
    row[2] = 20;
    row[3] = 20;
    row[4] = 0.9;
    row[6] = 1;
    final dets = SevenSegmentYoloPostprocess.decodeDetections(
      [row],
      scoreThreshold: 0.25,
      nmsIoU: 0.45,
      letterbox: letterbox,
    );
    expect(dets, hasLength(1));
    expect(dets.first.digit, 1);
    expect(dets.first.left, closeTo((96 - 10) / 192, 0.01));
    expect(dets.first.top, closeTo((96 - 10) / 192, 0.01));
    expect(dets.first.width, closeTo(20 / 192, 0.01));
  });

  test('score 0.1 は閾値未満で除外', () {
    final row = List<double>.filled(15, 0);
    row[4] = 0.1;
    row[5] = 1;
    final dets = SevenSegmentYoloPostprocess.decodeDetections(
      [row],
      scoreThreshold: 0.25,
      nmsIoU: 0.45,
      letterbox: letterbox,
    );
    expect(dets, isEmpty);
  });

  test('NMS で高 IoU の弱い検出を落とす', () {
    const hi = SevenSegmentDigitDetection(
      digit: 1,
      score: 0.9,
      left: 0.10,
      top: 0.10,
      width: 0.20,
      height: 0.20,
    );
    const lo = SevenSegmentDigitDetection(
      digit: 1,
      score: 0.8,
      left: 0.12,
      top: 0.12,
      width: 0.20,
      height: 0.20,
    );
    final kept = SevenSegmentYoloPostprocess.nonMaxSuppression([hi, lo], 0.45);
    expect(kept, hasLength(1));
    expect(kept.first.score, 0.9);
  });

  group('SevenSegmentDigitClusterer', () {
    test('同一行 1,2,3 小隙間で 123', () {
      const dets = [
        SevenSegmentDigitDetection(
          digit: 1,
          score: 1,
          left: 0.10,
          top: 0.20,
          width: 0.05,
          height: 0.08,
        ),
        SevenSegmentDigitDetection(
          digit: 2,
          score: 1,
          left: 0.16,
          top: 0.20,
          width: 0.05,
          height: 0.08,
        ),
        SevenSegmentDigitDetection(
          digit: 3,
          score: 1,
          left: 0.22,
          top: 0.20,
          width: 0.05,
          height: 0.08,
        ),
      ];
      final tokens = SevenSegmentDigitClusterer.clusterToTokens(dets);
      expect(tokens, hasLength(1));
      expect(tokens.first.text, '123');
    });

    test('広い隙間で 12.3', () {
      const dets = [
        SevenSegmentDigitDetection(
          digit: 1,
          score: 1,
          left: 0.10,
          top: 0.20,
          width: 0.05,
          height: 0.08,
        ),
        SevenSegmentDigitDetection(
          digit: 2,
          score: 1,
          left: 0.16,
          top: 0.20,
          width: 0.05,
          height: 0.08,
        ),
        SevenSegmentDigitDetection(
          digit: 3,
          score: 1,
          left: 0.40,
          top: 0.20,
          width: 0.05,
          height: 0.08,
        ),
      ];
      final tokens = SevenSegmentDigitClusterer.clusterToTokens(dets);
      expect(tokens.single.text, '12.3');
    });

    test('2 行でトークン 2 件', () {
      const dets = [
        SevenSegmentDigitDetection(
          digit: 1,
          score: 1,
          left: 0.10,
          top: 0.10,
          width: 0.05,
          height: 0.08,
        ),
        SevenSegmentDigitDetection(
          digit: 2,
          score: 1,
          left: 0.16,
          top: 0.10,
          width: 0.05,
          height: 0.08,
        ),
        SevenSegmentDigitDetection(
          digit: 3,
          score: 1,
          left: 0.10,
          top: 0.40,
          width: 0.05,
          height: 0.08,
        ),
      ];
      final tokens = SevenSegmentDigitClusterer.clusterToTokens(dets);
      expect(tokens, hasLength(2));
      expect(tokens[0].text, '12');
      expect(tokens[1].text, '3');
    });

    test('空入力', () {
      expect(SevenSegmentDigitClusterer.clusterToTokens(const []), isEmpty);
    });
  });
}
