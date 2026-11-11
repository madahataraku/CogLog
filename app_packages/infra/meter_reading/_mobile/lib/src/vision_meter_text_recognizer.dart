import 'package:flutter/services.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// iOS Vision によるメーター画像の文字列化。
///
/// Example:
/// ```dart
/// VisionMeterTextRecognizer();
/// ```
final class VisionMeterTextRecognizer implements MeterTextRecognizer {
  /// [methodChannel] を省略すると既定 channel を使う。
  ///
  /// Example:
  /// ```dart
  /// VisionMeterTextRecognizer();
  /// ```
  VisionMeterTextRecognizer({MethodChannel? methodChannel})
    : _channel =
          methodChannel ??
          const MethodChannel('infra_meter_reading/vision_ocr');

  /// Vision OCR MethodChannel。
  final MethodChannel _channel;

  /// [photoBytes] を Vision で認識する。失敗時は例外。
  ///
  /// Example:
  /// ```dart
  /// await VisionMeterTextRecognizer().recognize(Uint8List(0));
  /// ```
  @override
  Future<String> recognize(Uint8List photoBytes) async {
    final text = await _channel.invokeMethod<String>('recognizeText', {
      'imageBytes': photoBytes,
    });
    return text ?? '';
  }
}
