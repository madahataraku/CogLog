import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 画像から座標付き OCR トークン列を起こす窓口。
///
/// Example:
/// ```dart
/// await recognizer.recognizeLayout(Uint8List(0));
/// ```
abstract interface class MeterLayoutRecognizer {
  /// [photoBytes] からトークン列を返す。
  ///
  /// Example:
  /// ```dart
  /// await recognizer.recognizeLayout(Uint8List(0));
  /// ```
  Future<List<MeterOcrToken>> recognizeLayout(Uint8List photoBytes);

  /// 保持資源を解放する。
  ///
  /// Example:
  /// ```dart
  /// await recognizer.close();
  /// ```
  Future<void> close();
}
