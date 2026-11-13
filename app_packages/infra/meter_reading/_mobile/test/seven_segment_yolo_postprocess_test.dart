// ignore_for_file: avoid_relative_lib_imports

import 'package:flutter_test/flutter_test.dart';

import '../lib/src/seven_segment_digit_clusterer.dart';
import '../lib/src/seven_segment_digit_detection.dart';
import '../lib/src/seven_segment_letterbox_meta.dart';
import '../lib/src/seven_segment_yolo_postprocess.dart';

void main() {
  test('短い行、空行、面積のない検出、画像外の検出は除外する', () {
    final rows = <List<double>>[
      [],
      List.filled(14, 1),
      [96, 96, 0, 20, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [96, 96, 20, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      [-50, -50, 10, 10, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    ];
    expect(
      SevenSegmentYoloPostprocess.decodeDetections(
        rows,
        scoreThreshold: 0.25,
        nmsIoU: 0.45,
        letterbox: const SevenSegmentLetterboxMeta(
          scale: 1, padX: 0, padY: 0, srcWidth: 192, srcHeight: 192,
        ),
      ),
      isEmpty,
    );
  });

  test('閾値と等しい score を採用し letterbox の倍率と余白を戻す', () {
    final result = SevenSegmentYoloPostprocess.decodeDetections(
      [
        [48, 96, 48, 48, 0.25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1],
      ],
      scoreThreshold: 0.25,
      nmsIoU: 0.45,
      letterbox: const SevenSegmentLetterboxMeta(
        scale: 0.5, padX: 0, padY: 48, srcWidth: 384, srcHeight: 192,
      ),
    );
    expect(result.single.digit, 9);
    expect(result.single.score, 0.25);
    expect(result.single.left, 0.125);
    expect(result.single.top, 0.25);
    expect(result.single.width, 0.25);
    expect(result.single.height, 0.5);
  });

  test('NMS はクラスに関係なく最大 score を残し入力順を変えない', () {
    const a = SevenSegmentDigitDetection(
      digit: 1, score: 0.5, left: 0, top: 0, width: 0.5, height: 0.5,
    );
    const b = SevenSegmentDigitDetection(
      digit: 9, score: 0.9, left: 0, top: 0, width: 0.5, height: 0.5,
    );
    final input = [a, b];
    expect(SevenSegmentYoloPostprocess.nonMaxSuppression(input, 0.5), [b]);
    expect(input, [a, b]);
    // IoU と閾値が等しいときは抑制しない。
    expect(SevenSegmentYoloPostprocess.nonMaxSuppression(input, 1), [b, a]);
    expect(SevenSegmentYoloPostprocess.iou(a, b), 1);
  });

  test('交差しない矩形と面積ゼロの IoU はゼロ', () {
    const a = SevenSegmentDigitDetection(
      digit: 0, score: 1, left: 0, top: 0, width: 0.5, height: 0.5,
    );
    const b = SevenSegmentDigitDetection(
      digit: 0, score: 1, left: 0.5, top: 0, width: 0.5, height: 0.5,
    );
    const zero = SevenSegmentDigitDetection(
      digit: 0, score: 1, left: 0, top: 0, width: 0, height: 0,
    );
    expect(SevenSegmentYoloPostprocess.iou(a, b), 0);
    expect(SevenSegmentYoloPostprocess.iou(zero, zero), 0);
    expect(SevenSegmentYoloPostprocess.nonMaxSuppression([b, a], 0), [b, a]);
  });

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

  test('画像外にはみ出す矩形は端を切り詰めて幅を求める', () {
    final row = List<double>.filled(15, 0);
    row[0] = 5;
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
    expect(dets.first.left, 0);
    expect(dets.first.width, closeTo(15 / 192, 0.001));
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

    test('離れた数値群は別トークン', () {
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
          left: 0.65,
          top: 0.20,
          width: 0.05,
          height: 0.08,
        ),
        SevenSegmentDigitDetection(
          digit: 4,
          score: 1,
          left: 0.71,
          top: 0.20,
          width: 0.05,
          height: 0.08,
        ),
      ];
      final tokens = SevenSegmentDigitClusterer.clusterToTokens(dets);
      expect(tokens, hasLength(2));
      expect(tokens[0].text, '12');
      expect(tokens[1].text, '34');
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
