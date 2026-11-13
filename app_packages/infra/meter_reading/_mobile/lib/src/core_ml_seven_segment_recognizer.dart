import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/services.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

import 'seven_segment_digit_clusterer.dart';
import 'seven_segment_yolo_postprocess.dart';

/// iOS Core ML で七セグ桁テンソルを得る認識器。
///
/// Example:
/// ```dart
/// CoreMlSevenSegmentRecognizer();
/// ```
final class CoreMlSevenSegmentRecognizer
    implements MeterSevenSegmentRecognizer {
  /// [methodChannel] 省略時は `infra_meter_reading/seven_segment`。
  ///
  /// Example:
  /// ```dart
  /// CoreMlSevenSegmentRecognizer();
  /// ```
  CoreMlSevenSegmentRecognizer({
    MethodChannel? methodChannel,
    this.scoreThreshold = 0.25,
    this.nmsIoU = 0.45,
  }) : _channel =
           methodChannel ??
           const MethodChannel('infra_meter_reading/seven_segment');

  final MethodChannel _channel;

  /// 検出 score 閾値。
  final double scoreThreshold;

  /// NMS IoU 閾値。
  final double nmsIoU;

  /// letterbox → ネイティブ予測 → 共通後処理。
  ///
  /// Example:
  /// ```dart
  /// await CoreMlSevenSegmentRecognizer().recognize(Uint8List(0));
  /// ```
  @override
  Future<List<MeterOcrToken>> recognize(Uint8List photoBytes) async {
    final prepared = await SevenSegmentYoloPostprocess.decodeAndLetterbox(
      photoBytes,
    );
    if (prepared == null) {
      return const [];
    }
    final raw = await _channel.invokeMethod<List<dynamic>>(
      'predict',
      <String, Object?>{
        'inputFloat32': prepared.input.buffer.asUint8List(
          prepared.input.offsetInBytes,
          prepared.input.lengthInBytes,
        ),
        'width': 192,
        'height': 192,
        'channels': 3,
      },
    );
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    final rows = <List<double>>[
      for (final row in raw)
        [for (final v in (row as List<dynamic>)) (v as num).toDouble()],
    ];
    final dets = SevenSegmentYoloPostprocess.decodeDetections(
      rows,
      scoreThreshold: scoreThreshold,
      nmsIoU: nmsIoU,
      letterbox: prepared.letterbox,
    );
    return SevenSegmentDigitClusterer.clusterToTokens(dets);
  }

  /// MethodChannel のみのため解放対象はない。
  ///
  /// Example:
  /// ```dart
  /// await CoreMlSevenSegmentRecognizer().close();
  /// ```
  @override
  Future<void> close() async {}
}
