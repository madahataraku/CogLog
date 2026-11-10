import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

/// アプリ内カメラのプレビュー枠。
///
/// 与えられた領域を [aspectRatio]（幅÷高さ）を保ったまま全面で埋め、
/// はみ出しは中央基準で切り取る。
///
/// Example:
/// ```dart
/// MeterCaptureCameraPreview(
///   aspectRatio: 0.75,
///   preview: const SizedBox.shrink(),
/// );
/// ```
@internal
class MeterCaptureCameraPreview extends StatelessWidget {
  /// [aspectRatio] と [preview] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// MeterCaptureCameraPreview(
  ///   aspectRatio: 0.75,
  ///   preview: const SizedBox.shrink(),
  ///   debugPlaceholder: true,
  /// );
  /// ```
  const MeterCaptureCameraPreview({
    required this.aspectRatio,
    required this.preview,
    this.debugPlaceholder = false,
    super.key,
  });

  /// 表示上のプレビュー縦横比（幅 ÷ 高さ）。
  final double aspectRatio;

  /// Usecase 経由のライブプレビュー。
  final Widget preview;

  /// Golden では true にして色枠だけ出す。
  final bool debugPlaceholder;

  /// プレビューまたは色枠を描画する。
  ///
  /// Example:
  /// ```dart
  /// const MeterCaptureCameraPreview(
  ///   aspectRatio: 0.75,
  ///   preview: SizedBox.shrink(),
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    if (debugPlaceholder) {
      return const ColoredBox(
        color: Color(0xFF336699),
        child: SizedBox.expand(),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = aspectRatio > 0 ? aspectRatio : (3 / 4);
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;
        var width = maxWidth;
        var height = maxWidth / ratio;
        if (height < maxHeight) {
          height = maxHeight;
          width = maxHeight * ratio;
        }
        return ClipRect(
          child: SizedBox(
            width: maxWidth,
            height: maxHeight,
            child: Center(
              child: SizedBox(width: width, height: height, child: preview),
            ),
          ),
        );
      },
    );
  }
}
