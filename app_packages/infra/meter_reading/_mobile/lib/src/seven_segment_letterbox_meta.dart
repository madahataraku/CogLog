/// letterbox 変換のメタ（正規化座標へ戻すため）。
///
/// Example:
/// ```dart
/// const SevenSegmentLetterboxMeta(
///   scale: 0.5,
///   padX: 10,
///   padY: 0,
///   srcWidth: 364,
///   srcHeight: 192,
/// );
/// ```
final class SevenSegmentLetterboxMeta {
  /// 変換パラメータを保持する。
  ///
  /// Example:
  /// ```dart
  /// const SevenSegmentLetterboxMeta(
  ///   scale: 1,
  ///   padX: 0,
  ///   padY: 0,
  ///   srcWidth: 192,
  ///   srcHeight: 192,
  /// );
  /// ```
  const SevenSegmentLetterboxMeta({
    required this.scale,
    required this.padX,
    required this.padY,
    required this.srcWidth,
    required this.srcHeight,
  });

  /// 入力→192 への倍率。
  final double scale;

  /// 左右パディング（入力画素）。
  final double padX;

  /// 上下パディング（入力画素）。
  final double padY;

  /// 元画像幅。
  final double srcWidth;

  /// 元画像高さ。
  final double srcHeight;
}
