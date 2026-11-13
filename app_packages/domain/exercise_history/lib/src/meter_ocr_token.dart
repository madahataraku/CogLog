/// 座標付き OCR の 1 要素。
///
/// 矩形は画像正規化座標（0–1、原点は左上）。
///
/// Example:
/// ```dart
/// const MeterOcrToken(
///   text: '12.3',
///   left: 0.1,
///   top: 0.2,
///   width: 0.15,
///   height: 0.05,
/// );
/// ```
final class MeterOcrToken {
  /// [text] と正規化矩形でトークンを作る。
  ///
  /// Example:
  /// ```dart
  /// const MeterOcrToken(
  ///   text: 'km',
  ///   left: 0.3,
  ///   top: 0.2,
  ///   width: 0.08,
  ///   height: 0.04,
  /// );
  /// ```
  const MeterOcrToken({
    required this.text,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// 認識文字列。
  final String text;

  /// 左端（0–1）。
  final double left;

  /// 上端（0–1、左上原点）。
  final double top;

  /// 幅（0–1）。
  final double width;

  /// 高さ（0–1）。
  final double height;

  /// 中心 X。
  double get centerX => left + width / 2;

  /// 中心 Y。
  double get centerY => top + height / 2;
}
