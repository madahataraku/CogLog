import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
import 'package:meta/meta.dart';

/// 空間 OCR 強制フラグを書き換える。
///
/// Example:
/// ```dart
/// OnToggleForceSpatialOcrDelegate(
///   forceSpatialOcr: ForceSpatialOcrStore(),
/// ).execute(true);
/// ```
@internal
final class OnToggleForceSpatialOcrDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnToggleForceSpatialOcrDelegate(
  ///   forceSpatialOcr: ForceSpatialOcrStore(),
  /// );
  /// ```
  const OnToggleForceSpatialOcrDelegate({required this.forceSpatialOcr});

  /// 空間 OCR 強制ストア。
  final ForceSpatialOcrStore forceSpatialOcr;

  /// [enabled] をストアへ反映する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(true);
  /// ```
  void execute(bool enabled) {
    forceSpatialOcr.setEnabled(enabled);
  }
}
