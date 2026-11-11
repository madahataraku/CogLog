import 'dart:typed_data';

/// 画像バイトからパネル文字列を起こす OCR 窓口。
///
/// Example:
/// ```dart
/// await recognizer.recognize(Uint8List(0));
/// ```
abstract interface class MeterTextRecognizer {
  /// [photoBytes] から認識した生テキストを返す。
  ///
  /// Example:
  /// ```dart
  /// await recognizer.recognize(Uint8List(0));
  /// ```
  Future<String> recognize(Uint8List photoBytes);

  /// ネイティブ認識器など保持資源を解放する。
  ///
  /// Example:
  /// ```dart
  /// await recognizer.close();
  /// ```
  Future<void> close();
}
