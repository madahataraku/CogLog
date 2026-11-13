import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// 座標付き OCR と空間推論でメーター値を取るエンジン。
///
/// Example:
/// ```dart
/// SpatialOcrMeterReadingEngine(
///   kind: MeterReadingEngineKind.visionOcr,
///   recognizer: recognizer,
/// );
/// ```
final class SpatialOcrMeterReadingEngine implements MeterReadingEngine {
  /// [kind] と [recognizer] を持つ空間 OCR エンジンを作る。
  ///
  /// Example:
  /// ```dart
  /// SpatialOcrMeterReadingEngine(
  ///   kind: MeterReadingEngineKind.mlKit,
  ///   recognizer: recognizer,
  /// );
  /// ```
  const SpatialOcrMeterReadingEngine({
    required this.kind,
    required this.recognizer,
  });

  /// エンジン種別（iOS は visionOcr、Android は mlKit）。
  @override
  final MeterReadingEngineKind kind;

  /// 座標付き認識の実装。
  final MeterLayoutRecognizer recognizer;

  /// モバイルでは常に試す。失敗は [read] の例外として呼び出し側が握る。
  ///
  /// Example:
  /// ```dart
  /// await engine.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => true;

  /// [photoBytes] を認識し空間推論する。
  ///
  /// Example:
  /// ```dart
  /// await engine.read(Uint8List(0));
  /// ```
  @override
  Future<MeterReadingValues> read(Uint8List photoBytes) async {
    final tokens = await recognizer.recognizeLayout(photoBytes);
    return MeterSpatialLayoutInferencer.infer(tokens);
  }
}
