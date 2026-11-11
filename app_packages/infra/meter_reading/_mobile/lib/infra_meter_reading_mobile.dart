/// モバイル向けのメーター読み取りエンジン。
///
/// Example:
/// ```dart
/// OcrMeterReadingEngine(
///   kind: MeterReadingEngineKind.mlKit,
///   recognizer: MlKitMeterTextRecognizer(),
/// );
/// ```
library;

export 'src/llm_meter_reading_engine.dart';
export 'src/ml_kit_meter_text_recognizer.dart';
export 'src/ocr_meter_reading_engine.dart';
export 'src/unavailable_meter_reading_engine.dart';
