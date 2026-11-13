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

export 'src/core_ml_seven_segment_recognizer.dart';
export 'src/llm_meter_reading_engine.dart';
export 'src/ml_kit_meter_layout_recognizer.dart';
export 'src/ml_kit_meter_text_recognizer.dart';
export 'src/ocr_meter_reading_engine.dart';
export 'src/spatial_ocr_meter_reading_engine.dart';
export 'src/tflite_seven_segment_recognizer.dart';
export 'src/unavailable_meter_reading_engine.dart';
export 'src/vision_meter_layout_recognizer.dart';
export 'src/vision_meter_text_recognizer.dart';
