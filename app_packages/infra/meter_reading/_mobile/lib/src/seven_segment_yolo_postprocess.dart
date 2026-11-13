import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'seven_segment_digit_detection.dart';
import 'seven_segment_letterbox_meta.dart';

/// Swift-YOLO 七セグ検出の前処理と後処理。
abstract final class SevenSegmentYoloPostprocess {
  /// 画像を 192 letterbox RGB float にする。失敗時は null。
  ///
  /// Example:
  /// ```dart
  /// await SevenSegmentYoloPostprocess.decodeAndLetterbox(Uint8List(0));
  /// ```
  static Future<({Float32List input, SevenSegmentLetterboxMeta letterbox})?>
  decodeAndLetterbox(Uint8List bytes, {int inputSize = 192}) async {
    ui.Codec? codec;
    try {
      codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final srcW = image.width.toDouble();
      final srcH = image.height.toDouble();
      if (srcW <= 0 || srcH <= 0) {
        return null;
      }
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      image.dispose();
      if (byteData == null) {
        return null;
      }
      final rgba = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      final scale = inputSize / math.max(srcW, srcH);
      final newW = srcW * scale;
      final newH = srcH * scale;
      final padX = (inputSize - newW) / 2;
      final padY = (inputSize - newH) / 2;
      final out = Float32List(1 * inputSize * inputSize * 3);
      for (var i = 0; i < out.length; i++) {
        out[i] = 114 / 255.0;
      }
      for (var y = 0; y < srcH.toInt(); y++) {
        for (var x = 0; x < srcW.toInt(); x++) {
          final dx = (x * scale + padX).floor();
          final dy = (y * scale + padY).floor();
          if (dx < 0 || dy < 0 || dx >= inputSize || dy >= inputSize) {
            continue;
          }
          final si = (y * srcW.toInt() + x) * 4;
          final oi = (dy * inputSize + dx) * 3;
          out[oi] = rgba[si] / 255.0;
          out[oi + 1] = rgba[si + 1] / 255.0;
          out[oi + 2] = rgba[si + 2] / 255.0;
        }
      }
      return (
        input: out,
        letterbox: SevenSegmentLetterboxMeta(
          scale: scale,
          padX: padX,
          padY: padY,
          srcWidth: srcW,
          srcHeight: srcH,
        ),
      );
    } on Object {
      // 壊れた画像バイトは補完不能。呼び出し側へ null。
      return null;
    } finally {
      codec?.dispose();
    }
  }

  /// 生出力行を正規化座標の桁検出へ写す。
  ///
  /// Example:
  /// ```dart
  /// SevenSegmentYoloPostprocess.decodeDetections(
  ///   const [],
  ///   scoreThreshold: 0.25,
  ///   nmsIoU: 0.45,
  ///   letterbox: SevenSegmentLetterboxMeta(
  ///     scale: 1,
  ///     padX: 0,
  ///     padY: 0,
  ///     srcWidth: 192,
  ///     srcHeight: 192,
  ///   ),
  /// );
  /// ```
  static List<SevenSegmentDigitDetection> decodeDetections(
    List<List<double>> rows, {
    required double scoreThreshold,
    required double nmsIoU,
    required SevenSegmentLetterboxMeta letterbox,
  }) {
    final raw = <SevenSegmentDigitDetection>[];
    for (final row in rows) {
      if (row.length < 15) {
        continue;
      }
      final score = row[4];
      if (score < scoreThreshold) {
        continue;
      }
      var digit = 0;
      var best = row[5];
      for (var c = 1; c < 10; c++) {
        if (row[5 + c] > best) {
          best = row[5 + c];
          digit = c;
        }
      }
      final cx = row[0];
      final cy = row[1];
      final w = row[2];
      final h = row[3];
      final leftPx = (cx - w / 2 - letterbox.padX) / letterbox.scale;
      final topPx = (cy - h / 2 - letterbox.padY) / letterbox.scale;
      final widthPx = w / letterbox.scale;
      final heightPx = h / letterbox.scale;
      final left = (leftPx / letterbox.srcWidth).clamp(0.0, 1.0);
      final top = (topPx / letterbox.srcHeight).clamp(0.0, 1.0);
      final width = (widthPx / letterbox.srcWidth).clamp(0.0, 1.0 - left);
      final height = (heightPx / letterbox.srcHeight).clamp(0.0, 1.0 - top);
      raw.add(
        SevenSegmentDigitDetection(
          digit: digit,
          score: score,
          left: left,
          top: top,
          width: width,
          height: height,
        ),
      );
    }
    return nonMaxSuppression(raw, nmsIoU);
  }

  /// スコア降順の class-agnostic NMS。
  ///
  /// Example:
  /// ```dart
  /// SevenSegmentYoloPostprocess.nonMaxSuppression(const [], 0.45);
  /// ```
  static List<SevenSegmentDigitDetection> nonMaxSuppression(
    List<SevenSegmentDigitDetection> dets,
    double iouThreshold,
  ) {
    final sorted = [...dets]..sort((a, b) => b.score.compareTo(a.score));
    final kept = <SevenSegmentDigitDetection>[];
    final suppressed = List<bool>.filled(sorted.length, false);
    for (var i = 0; i < sorted.length; i++) {
      if (suppressed[i]) {
        continue;
      }
      kept.add(sorted[i]);
      for (var j = i + 1; j < sorted.length; j++) {
        if (suppressed[j]) {
          continue;
        }
        if (iou(sorted[i], sorted[j]) > iouThreshold) {
          suppressed[j] = true;
        }
      }
    }
    return kept;
  }

  /// 交差面積／和面積。
  ///
  /// Example:
  /// ```dart
  /// SevenSegmentYoloPostprocess.iou(
  ///   const SevenSegmentDigitDetection(
  ///     digit: 1,
  ///     score: 1,
  ///     left: 0,
  ///     top: 0,
  ///     width: 0.5,
  ///     height: 0.5,
  ///   ),
  ///   const SevenSegmentDigitDetection(
  ///     digit: 2,
  ///     score: 1,
  ///     left: 0.25,
  ///     top: 0.25,
  ///     width: 0.5,
  ///     height: 0.5,
  ///   ),
  /// );
  /// ```
  static double iou(
    SevenSegmentDigitDetection a,
    SevenSegmentDigitDetection b,
  ) {
    final left = math.max(a.left, b.left);
    final top = math.max(a.top, b.top);
    final right = math.min(a.right, b.right);
    final bottom = math.min(a.bottom, b.bottom);
    final iw = math.max(0.0, right - left);
    final ih = math.max(0.0, bottom - top);
    final inter = iw * ih;
    final uni = a.width * a.height + b.width * b.height - inter;
    if (uni <= 0) {
      return 0;
    }
    return inter / uni;
  }
}
