import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';

/// ML Kit Text Recognition でメーター画像を文字列化する。
///
/// 圧縮画像はデコードして [InputImage.fromBitmap] を優先し、失敗時だけ一時ファイルへ書く。
/// [InputImage.fromBytes] は生フレーム用メタデータが要るため、JPEG/PNG では使えない。
///
/// Example:
/// ```dart
/// MlKitMeterTextRecognizer();
/// ```
final class MlKitMeterTextRecognizer implements MeterTextRecognizer {
  /// [recognizer] を省略すると日本語スクリプトの既定実装を使う。
  ///
  /// Example:
  /// ```dart
  /// MlKitMeterTextRecognizer();
  /// ```
  MlKitMeterTextRecognizer({TextRecognizer? recognizer})
    : _recognizer =
          recognizer ?? TextRecognizer(script: TextRecognitionScript.japanese);

  /// 認識本体。
  final TextRecognizer _recognizer;

  /// [photoBytes] を認識し、失敗時は例外を投げて一時ファイルを残さない。
  ///
  /// Example:
  /// ```dart
  /// await MlKitMeterTextRecognizer().recognize(Uint8List(0));
  /// ```
  @override
  Future<String> recognize(Uint8List photoBytes) async {
    final fromDecoded = await _tryRecognizeFromDecodedBytes(photoBytes);
    if (fromDecoded != null) {
      return fromDecoded;
    }
    return _recognizeViaTempFile(photoBytes);
  }

  /// JPEG/PNG を RGBA にデコードできればディスク非経由で認識する。
  ///
  /// Example:
  /// ```dart
  /// await recognizer._tryRecognizeFromDecodedBytes(Uint8List(0));
  /// ```
  Future<String?> _tryRecognizeFromDecodedBytes(Uint8List photoBytes) async {
    try {
      final codec = await ui.instantiateImageCodec(photoBytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;
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
      return recognized.text;
    } on Object {
      // デコード不能や raw 認識失敗は一時ファイル経路へ。
      return null;
    }
  }

  /// 一時ファイル経由で認識し、成否にかかわらず削除する。
  ///
  /// Example:
  /// ```dart
  /// await recognizer._recognizeViaTempFile(Uint8List(0));
  /// ```
  Future<String> _recognizeViaTempFile(Uint8List photoBytes) async {
    final directory = await Directory.systemTemp.createTemp('meter_ocr_');
    final file = File('${directory.path}/panel.jpg');
    try {
      await file.writeAsBytes(photoBytes, flush: true);
      final input = InputImage.fromFilePath(file.path);
      final recognized = await _recognizer.processImage(input);
      return recognized.text;
    } finally {
      await _deleteQuietly(file);
      await _deleteQuietly(directory);
    }
  }

  /// 存在すれば削除し、失敗は握りつぶす。
  ///
  /// Example:
  /// ```dart
  /// await recognizer._deleteQuietly(File('x'));
  /// ```
  Future<void> _deleteQuietly(FileSystemEntity entity) async {
    try {
      if (await entity.exists()) {
        await entity.delete(recursive: true);
      }
    } on Object {
      // 一時ファイル掃除の失敗は呼び出し元へ伝えない。
    }
  }
}
