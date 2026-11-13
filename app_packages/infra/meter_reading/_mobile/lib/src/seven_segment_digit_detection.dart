/// 七セグ 1 桁の検出結果（画像正規化座標）。
///
/// Example:
/// ```dart
/// const SevenSegmentDigitDetection(
///   digit: 1,
///   score: 0.9,
///   left: 0.1,
///   top: 0.2,
///   width: 0.05,
///   height: 0.08,
/// );
/// ```
final class SevenSegmentDigitDetection {
  /// 桁と正規化矩形で検出を作る。
  ///
  /// Example:
  /// ```dart
  /// const SevenSegmentDigitDetection(
  ///   digit: 0,
  ///   score: 0.5,
  ///   left: 0,
  ///   top: 0,
  ///   width: 0.1,
  ///   height: 0.1,
  /// );
  /// ```
  const SevenSegmentDigitDetection({
    required this.digit,
    required this.score,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// 0–9。
  final int digit;

  /// モデル score。
  final double score;

  /// 左端 0–1。
  final double left;

  /// 上端 0–1。
  final double top;

  /// 幅 0–1。
  final double width;

  /// 高さ 0–1。
  final double height;

  /// 中心 X。
  double get centerX => left + width / 2;

  /// 中心 Y。
  double get centerY => top + height / 2;

  /// 右端。
  double get right => left + width;

  /// 下端。
  double get bottom => top + height;
}
