import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// ML Kit で座標付きトークン列を起こす。
///
/// Example:
/// ```dart
/// MlKitMeterLayoutRecognizer();
/// ```
final class MlKitMeterLayoutRecognizer implements MeterLayoutRecognizer {
  /// [recognizer] を省略すると日本語スクリプトの既定実装を使う。
  ///
  /// Example:
  /// ```dart
  /// MlKitMeterLayoutRecognizer();
  /// ```
  MlKitMeterLayoutRecognizer({TextRecognizer? recognizer})
    : _recognizer =
          recognizer ?? TextRecognizer(script: TextRecognitionScript.japanese);

  /// 文字認識本体。保持資源は [close] で解放する。
  final TextRecognizer _recognizer;

  /// [photoBytes] を認識し要素単位のトークンを返す。
  ///
  /// Example:
  /// ```dart
  /// await MlKitMeterLayoutRecognizer().recognizeLayout(Uint8List(0));
  /// ```
  @override
  Future<List<MeterOcrToken>> recognizeLayout(Uint8List photoBytes) async {
    final fromDecoded = await _tryFromDecoded(photoBytes);
    if (fromDecoded != null) {
      return fromDecoded;
    }
    return _viaTempFile(photoBytes);
  }

  /// [TextRecognizer] を閉じる。
  ///
  /// Example:
  /// ```dart
  /// await MlKitMeterLayoutRecognizer().close();
  /// ```
  @override
  Future<void> close() => _recognizer.close();

  /// JPEG/PNG を RGBA にできればディスク非経由で要素トークンを返す。
  ///
  /// Example:
  /// ```dart
  /// await recognizer._tryFromDecoded(Uint8List(0));
  /// ```
  Future<List<MeterOcrToken>?> _tryFromDecoded(Uint8List photoBytes) async {
    ui.Codec? codec;
    ui.Image? image;
    try {
      codec = await ui.instantiateImageCodec(photoBytes);
      final frame = await codec.getNextFrame();
      image = frame.image;
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) {
        return null;
      }
      final input = InputImage.fromBitmap(
        bitmap: byteData.buffer.asUint8List(),
        width: image.width,
        height: image.height,
      );
      final recognized = await _recognizer.processImage(input);
      return _tokensFrom(
        recognized,
        imageWidth: image.width.toDouble(),
        imageHeight: image.height.toDouble(),
      );
    } on Object {
      return null;
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }

  /// 一時ファイル経由で認識し、画像サイズで正規化する。
  ///
  /// Example:
  /// ```dart
  /// await recognizer._viaTempFile(Uint8List(0));
  /// ```
  Future<List<MeterOcrToken>> _viaTempFile(Uint8List photoBytes) async {
    final directory = await Directory.systemTemp.createTemp('meter_layout_');
    final file = File('${directory.path}/panel.jpg');
    try {
      await file.writeAsBytes(photoBytes, flush: true);
      final input = InputImage.fromFilePath(file.path);
      final recognized = await _recognizer.processImage(input);
      final decoded = await ui.instantiateImageCodec(photoBytes);
      final frame = await decoded.getNextFrame();
      final image = frame.image;
      try {
        return _tokensFrom(
          recognized,
          imageWidth: image.width.toDouble(),
          imageHeight: image.height.toDouble(),
        );
      } finally {
        image.dispose();
        decoded.dispose();
      }
    } finally {
      try {
        if (await file.exists()) {
          await file.delete();
        }
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      } on Object {
        // 掃除失敗は握りつぶす。
      }
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
