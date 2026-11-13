import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 画像全体から七セグ由来の数値トークン列を起こす窓口。
///
/// Example:
/// ```dart
/// await recognizer.recognize(Uint8List(0));
/// ```
abstract interface class MeterSevenSegmentRecognizer {
  /// [photoBytes] から数値候補トークンを返す。
  ///
  /// 画像デコード失敗など補完不能時は空列。モデル未ロード等の致命失敗は例外でよい
  ///（エンジンが握る）。
  ///
  /// Example:
  /// ```dart
  /// await recognizer.recognize(Uint8List(0));
  /// ```
  Future<List<MeterOcrToken>> recognize(Uint8List photoBytes);

  /// 保持資源を解放する（本番エンジンからは呼ばない。テスト用）。
  ///
  /// Example:
  /// ```dart
  /// await recognizer.close();
  /// ```
  Future<void> close();
}
