import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

import 'ml_kit_recognized_text_loader.dart';

/// ML Kit で座標付きトークン列を起こす。
///
/// 日本語スクリプトが失敗したときはラテンへ落とす。
///
/// Example:
/// ```dart
/// MlKitMeterLayoutRecognizer();
/// ```
final class MlKitMeterLayoutRecognizer implements MeterLayoutRecognizer {
  /// [loader] を省略すると日本語→ラテンの既定ローダーを使う。
  ///
  /// Example:
  /// ```dart
  /// MlKitMeterLayoutRecognizer();
  /// ```
  MlKitMeterLayoutRecognizer({MlKitRecognizedTextLoader? loader})
    : _loader = loader ?? MlKitRecognizedTextLoader(),
      _ownsLoader = loader == null;

  final MlKitRecognizedTextLoader _loader;
  final bool _ownsLoader;

  /// [photoBytes] を認識し要素単位のトークンを返す。
  ///
  /// Example:
  /// ```dart
  /// await MlKitMeterLayoutRecognizer().recognizeLayout(Uint8List(0));
  /// ```
  @override
  Future<List<MeterOcrToken>> recognizeLayout(Uint8List photoBytes) async {
    final loaded = await _loader.load(photoBytes);
    return _tokensFrom(
      loaded.recognized,
      imageWidth: loaded.imageWidth,
      imageHeight: loaded.imageHeight,
    );
  }

  /// 保持する認識資源を閉じる。
  ///
  /// Example:
  /// ```dart
  /// await MlKitMeterLayoutRecognizer().close();
  /// ```
  @override
  Future<void> close() async {
    if (_ownsLoader) {
      await _loader.close();
    }
  }

  /// [TextElement] 単位で正規化矩形付きトークンへ写す。
  ///
  /// Example:
  /// ```dart
  /// recognizer._tokensFrom(recognized, imageWidth: 100, imageHeight: 100);
  /// ```
  List<MeterOcrToken> _tokensFrom(
    RecognizedText recognized, {
    required double imageWidth,
    required double imageHeight,
  }) {
    if (imageWidth <= 0 || imageHeight <= 0) {
      return const [];
    }
    final tokens = <MeterOcrToken>[];
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        for (final element in line.elements) {
          final box = element.boundingBox;
          tokens.add(
            MeterOcrToken(
              text: element.text,
              left: box.left / imageWidth,
              top: box.top / imageHeight,
              width: box.width / imageWidth,
              height: box.height / imageHeight,
            ),
          );
        }
      }
    }
    return tokens;
  }
}
