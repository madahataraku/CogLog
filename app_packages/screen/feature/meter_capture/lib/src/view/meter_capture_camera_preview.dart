import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

/// アプリ内カメラのプレビュー枠。
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

  /// プレビュー縦横比。
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
    return Center(
      child: AspectRatio(aspectRatio: aspectRatio, child: preview),
    );
  }
}
