import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter/services.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// iOS Vision による座標付きトークン列。
///
/// Example:
/// ```dart
/// VisionMeterLayoutRecognizer();
/// ```
final class VisionMeterLayoutRecognizer implements MeterLayoutRecognizer {
  /// [methodChannel] を省略すると既定 channel を使う。
  ///
  /// Example:
  /// ```dart
  /// VisionMeterLayoutRecognizer();
  /// ```
  VisionMeterLayoutRecognizer({MethodChannel? methodChannel})
    : _channel =
          methodChannel ??
          const MethodChannel('infra_meter_reading/vision_ocr');

  final MethodChannel _channel;

  /// [photoBytes] を Vision で認識する。
  ///
  /// Example:
  /// ```dart
  /// await VisionMeterLayoutRecognizer().recognizeLayout(Uint8List(0));
  /// ```
  @override
  Future<List<MeterOcrToken>> recognizeLayout(Uint8List photoBytes) async {
    final raw = await _channel.invokeMethod<List<dynamic>>('recognizeLayout', {
      'imageBytes': photoBytes,
    });
    if (raw == null) {
      return const [];
    }
    return [
      for (final item in raw)
        if (item is Map)
          MeterOcrToken(
            text: '${item['text'] ?? ''}',
            left: (item['left'] as num?)?.toDouble() ?? 0,
            top: (item['top'] as num?)?.toDouble() ?? 0,
            width: (item['width'] as num?)?.toDouble() ?? 0,
            height: (item['height'] as num?)?.toDouble() ?? 0,
          ),
    ];
  }

  /// MethodChannel のみのため解放対象はない。
  ///
  /// Example:
  /// ```dart
  /// await VisionMeterLayoutRecognizer().close();
  /// ```
  @override
  Future<void> close() async {}
}
