import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// `threeArchedCircle` による不定ローディング表示。
///
/// 既定サイズは 64 論理ピクセル。色はテーマの primary。
///
/// Example:
/// ```dart
/// const AppLoadingSpinner();
/// ```
final class AppLoadingSpinner extends StatelessWidget {
  /// [size] 未指定時は [defaultSize]。
  ///
  /// Example:
  /// ```dart
  /// const AppLoadingSpinner();
  /// ```
  const AppLoadingSpinner({super.key, this.size = defaultSize});

  /// 要件で定めた既定の一辺（論理ピクセル）。
  static const double defaultSize = 64;

  /// 一辺の論理ピクセル。
  final double size;

  /// primary 色の `threeArchedCircle` を返す。
  ///
  /// Example:
  /// ```dart
  /// const AppLoadingSpinner().build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.threeArchedCircle(
      color: context.theme.colors.primary,
      size: size,
    );
  }
}
