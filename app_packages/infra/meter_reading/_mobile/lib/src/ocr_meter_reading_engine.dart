import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// OCR 認識結果を [MeterPanelTextParser] で値へ写すエンジン。
///
/// Example:
/// ```dart
/// OcrMeterReadingEngine(
///   kind: MeterReadingEngineKind.mlKit,
///   recognizer: MlKitMeterTextRecognizer(),
/// );
/// ```
final class OcrMeterReadingEngine implements MeterReadingEngine {
  /// [kind] と [recognizer] を持つ OCR エンジンを作る。
  ///
  /// Example:
  /// ```dart
  /// OcrMeterReadingEngine(
  ///   kind: MeterReadingEngineKind.visionOcr,
  ///   recognizer: MlKitMeterTextRecognizer(),
  /// );
  /// ```
  const OcrMeterReadingEngine({required this.kind, required this.recognizer});

  /// エンジン種別（iOS は visionOcr、Android は mlKit）。
  @override
  final MeterReadingEngineKind kind;

  /// 文字列認識の実装。
  final MeterTextRecognizer recognizer;

  /// 端末 OCR は常に試す。失敗は [read] の例外として呼び出し側が次へ進める。
  ///
  /// Example:
  /// ```dart
  /// await engine.isAvailable;
  /// ```
  @override
  Future<bool> get isAvailable async => true;

  /// [photoBytes] を認識して [MeterPanelTextParser.parse] する。
  ///
  /// Example:
  /// ```dart
  /// await engine.read(Uint8List(0));
  /// ```
  @override
  Future<MeterReadingValues> read(Uint8List photoBytes) async {
    final text = await recognizer.recognize(photoBytes);
    return MeterPanelTextParser.parse(text);
  }
}
