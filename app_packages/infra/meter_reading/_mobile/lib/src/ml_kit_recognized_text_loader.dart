import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// 日本語認識が失敗したときのラテン再試行。
///
/// 両方失敗したときは最初の（日本語側の）例外を投げる。
///
/// Example:
/// ```dart
/// await runJapaneseThenLatin(
///   japanese: () async => 'ja',
///   latin: () async => 'la',
/// );
/// ```
@visibleForTesting
Future<T> runJapaneseThenLatin<T>({
  required Future<T> Function() japanese,
  required Future<T> Function() latin,
}) async {
  late final Object japaneseError;
  try {
    return await japanese();
  } on Object catch (error) {
    japaneseError = error;
  }
  try {
    return await latin();
  } on Object {
    Error.throwWithStackTrace(japaneseError, StackTrace.current);
  }
}

/// ML Kit 認識結果と正規化用の画像サイズ。
///
/// Example:
/// ```dart
/// MlKitRecognizedImage(
///   recognized: recognized,
///   imageWidth: 100,
///   imageHeight: 80,
/// );
/// ```
final class MlKitRecognizedImage {
  /// [recognized] と画素サイズを持つ。
  ///
  /// Example:
  /// ```dart
  /// MlKitRecognizedImage(
  ///   recognized: recognized,
  ///   imageWidth: 100,
  ///   imageHeight: 80,
  /// );
  /// ```
  const MlKitRecognizedImage({
    required this.recognized,
    required this.imageWidth,
    required this.imageHeight,
  });

  /// ML Kit の認識結果。
  final RecognizedText recognized;

  /// 画像幅（px）。
  final double imageWidth;

  /// 画像高さ（px）。
  final double imageHeight;
}

/// ML Kit の [RecognizedText] を画像バイトから読み出す。
///
/// 日本語スクリプトを先に試し、失敗したらラテンへ落とす。
/// 圧縮画像は RGBA デコード経由を優先し、デコード不能のときだけ一時ファイルを使う。
///
/// Example:
/// ```dart
/// await MlKitRecognizedTextLoader().load(Uint8List(0));
/// ```
final class MlKitRecognizedTextLoader {
  /// [japanese] / [latin] を省略すると既定のスクリプト別 [TextRecognizer] を持つ。
  ///
  /// Example:
  /// ```dart
  /// MlKitRecognizedTextLoader();
  /// ```
  MlKitRecognizedTextLoader({TextRecognizer? japanese, TextRecognizer? latin})
    : _japanese =
          japanese ?? TextRecognizer(script: TextRecognitionScript.japanese),
      _latin = latin ?? TextRecognizer(script: TextRecognitionScript.latin),
      _ownsJapanese = japanese == null,
      _ownsLatin = latin == null;

  final TextRecognizer _japanese;
  final TextRecognizer _latin;
  final bool _ownsJapanese;
  final bool _ownsLatin;

  /// 直前に成功したスクリプト。失敗だけのときは null。
  ///
  /// Example:
  /// ```dart
  /// loader.lastScript;
  /// ```
  @visibleForTesting
  TextRecognitionScript? get lastScript => _lastScript;
  TextRecognitionScript? _lastScript;

  /// [photoBytes] を認識する。日本語が失敗したらラテンで再試行する。
  ///
  /// Example:
  /// ```dart
  /// await MlKitRecognizedTextLoader().load(Uint8List(0));
  /// ```
  Future<MlKitRecognizedImage> load(Uint8List photoBytes) async {
    _lastScript = null;
    return runJapaneseThenLatin(
      japanese: () async {
        final image = await _loadWith(_japanese, photoBytes);
        _lastScript = TextRecognitionScript.japanese;
        return image;
      },
      latin: () async {
        final image = await _loadWith(_latin, photoBytes);
        _lastScript = TextRecognitionScript.latin;
        return image;
      },
    );
  }

  /// 保持する [TextRecognizer] を閉じる。
  ///
  /// Example:
  /// ```dart
  /// await MlKitRecognizedTextLoader().close();
  /// ```
  Future<void> close() async {
    if (_ownsJapanese) {
      await _japanese.close();
    }
    if (_ownsLatin) {
      await _latin.close();
    }
  }

  /// 1 スクリプトでデコード経路→一時ファイルの順に試す。
  ///
  /// Example:
  /// ```dart
  /// await loader._loadWith(recognizer, Uint8List(0));
  /// ```
  Future<MlKitRecognizedImage> _loadWith(
    TextRecognizer recognizer,
    Uint8List photoBytes,
  ) async {
    final decoded = await _tryFromDecoded(recognizer, photoBytes);
    if (decoded != null) {
      return decoded;
    }
    return _viaTempFile(recognizer, photoBytes);
  }

  /// JPEG/PNG を RGBA にできればディスク非経由で認識する。
  ///
  /// デコード失敗だけ null。認識例外はそのまま投げる。
  ///
  /// Example:
  /// ```dart
  /// await loader._tryFromDecoded(recognizer, Uint8List(0));
  /// ```
  Future<MlKitRecognizedImage?> _tryFromDecoded(
    TextRecognizer recognizer,
    Uint8List photoBytes,
  ) async {
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
      final recognized = await recognizer.processImage(input);
      return MlKitRecognizedImage(
        recognized: recognized,
        imageWidth: image.width.toDouble(),
        imageHeight: image.height.toDouble(),
      );
    } on Object {
      // デコード段階の失敗は一時ファイルへ。認識例外は呼び出し元へ。
      if (image == null) {
        return null;
      }
      rethrow;
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }

  /// 一時ファイル経由で認識し、画像サイズは別途デコードして取る。
  ///
  /// Example:
  /// ```dart
  /// await loader._viaTempFile(recognizer, Uint8List(0));
  /// ```
  Future<MlKitRecognizedImage> _viaTempFile(
    TextRecognizer recognizer,
    Uint8List photoBytes,
  ) async {
    final directory = await Directory.systemTemp.createTemp('meter_mlkit_');
    final file = File('${directory.path}/panel.jpg');
    try {
      await file.writeAsBytes(photoBytes, flush: true);
      final input = InputImage.fromFilePath(file.path);
      final recognized = await recognizer.processImage(input);
      final size = await _decodeSize(photoBytes);
      return MlKitRecognizedImage(
        recognized: recognized,
        imageWidth: size.$1,
        imageHeight: size.$2,
      );
    } finally {
      await _deleteQuietly(file);
      await _deleteQuietly(directory);
    }
  }

  /// 画像バイトの幅と高さを読む。失敗時は (1, 1)。
  ///
  /// Example:
  /// ```dart
  /// await loader._decodeSize(Uint8List(0));
  /// ```
  Future<(double, double)> _decodeSize(Uint8List photoBytes) async {
    ui.Codec? codec;
    ui.Image? image;
    try {
      codec = await ui.instantiateImageCodec(photoBytes);
      final frame = await codec.getNextFrame();
      image = frame.image;
      return (image.width.toDouble(), image.height.toDouble());
    } on Object {
      return (1.0, 1.0);
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }

  /// 存在すれば削除し、失敗は握りつぶす。
  ///
  /// Example:
  /// ```dart
  /// await loader._deleteQuietly(File('x'));
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
