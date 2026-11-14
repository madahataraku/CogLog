import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/services.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'seven_segment_digit_clusterer.dart';
import 'seven_segment_yolo_postprocess.dart';

/// TFLite で七セグ桁検出を行う認識器（Android）。
///
/// Example:
/// ```dart
/// TfLiteSevenSegmentRecognizer();
/// ```
final class TfLiteSevenSegmentRecognizer
    implements MeterSevenSegmentRecognizer {
  /// アセットからモデルを lazy load する認識器。
  ///
  /// Example:
  /// ```dart
  /// TfLiteSevenSegmentRecognizer();
  /// ```
  TfLiteSevenSegmentRecognizer({
    this.assetKey =
        'packages/infra_meter_reading_mobile/assets/seven_segment/'
        'seven_segment_swift_yolo_192_float32.tflite',
    this.scoreThreshold = 0.25,
    this.nmsIoU = 0.45,
  });

  /// rootBundle 用アセットキー。
  final String assetKey;

  /// 検出 score 閾値。
  final double scoreThreshold;

  /// NMS IoU 閾値。
  final double nmsIoU;
  Interpreter? _interpreter;

  /// バンドルから Interpreter を一度だけ載せる。
  ///
  /// Example:
  /// ```dart
  /// final r = TfLiteSevenSegmentRecognizer();
  /// await r.recognize(Uint8List(0));
  /// ```
  Future<void> _ensureLoaded() async {
    if (_interpreter != null) {
      return;
    }
    final data = await rootBundle.load(assetKey);
    final interpreter = Interpreter.fromBuffer(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
    );
    _interpreter = interpreter;
  }

  /// モデルを実行し数値トークン列を返す。
  ///
  /// Example:
  /// ```dart
  /// await TfLiteSevenSegmentRecognizer().recognize(Uint8List(0));
  /// ```
  @override
  Future<List<MeterOcrToken>> recognize(Uint8List photoBytes) async {
    await _ensureLoaded();
    final interpreter = _interpreter;
    if (interpreter == null) {
      return const [];
    }
    final prepared = await SevenSegmentYoloPostprocess.decodeAndLetterbox(
      photoBytes,
    );
    if (prepared == null) {
      return const [];
    }
    final outShape = interpreter.getOutputTensor(0).shape;
    late final List<List<double>> rows;
    if (outShape.length == 3 &&
        outShape[0] == 1 &&
        outShape[1] == 2268 &&
        outShape[2] == 15) {
      final out = List.generate(
        1,
        (_) => List.generate(2268, (_) => List.filled(15, 0.0)),
      );
      interpreter.run(prepared.input.reshape([1, 192, 192, 3]), out);
      rows = out[0];
    } else if (outShape.length == 2 &&
        outShape[0] == 2268 &&
        outShape[1] == 15) {
      final out = List.generate(2268, (_) => List.filled(15, 0.0));
      interpreter.run(prepared.input.reshape([1, 192, 192, 3]), out);
      rows = out;
    } else {
      // 想定外 shape。補完不能として空を返す（エンジンは汎用のみ継続）。
      return const [];
    }
    final dets = SevenSegmentYoloPostprocess.decodeDetections(
      rows,
      scoreThreshold: scoreThreshold,
      nmsIoU: nmsIoU,
      letterbox: prepared.letterbox,
    );
    return SevenSegmentDigitClusterer.clusterToTokens(dets);
  }

  /// Interpreter を閉じる（テスト用）。
  ///
  /// Example:
  /// ```dart
  /// await TfLiteSevenSegmentRecognizer().close();
  /// ```
  @override
  Future<void> close() async {
    _interpreter?.close();
    _interpreter = null;
  }
}
