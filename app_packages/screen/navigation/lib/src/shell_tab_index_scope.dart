import 'package:flutter/widgets.dart';

/// ボトムナビの選択中タブを子孫へ伝える。
///
/// [index] の 0 がホーム。IndexedStack で保持された画面が、タブ復帰を
/// 検知するために使う。
///
/// Example:
/// ```dart
/// ShellTabIndexScope(
///   index: 0,
///   child: child,
/// );
/// ```
final class ShellTabIndexScope extends InheritedWidget {
  /// [index] を [child] 配下へ公開する。
  ///
  /// Example:
  /// ```dart
  /// ShellTabIndexScope(index: 0, child: child);
  /// ```
  const ShellTabIndexScope({
    required this.index,
    required super.child,
    super.key,
  });

  /// 選択中タブ。0 がホーム。
  final int index;

  /// 祖先の [ShellTabIndexScope] の [index] を返す。
  ///
  /// Example:
  /// ```dart
  /// ShellTabIndexScope.of(context);
  /// ```
  static int of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ShellTabIndexScope>();
    assert(scope != null, 'ShellTabIndexScope が見つからない');
    return scope!.index;
  }

  /// 祖先が無いときは null。
  ///
  /// Example:
  /// ```dart
  /// ShellTabIndexScope.maybeOf(context);
  /// ```
  static int? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellTabIndexScope>()?.index;

  /// [index] が変わったときだけ通知する。
  ///
  /// Example:
  /// ```dart
  /// scope.updateShouldNotify(oldScope);
  /// ```
  @override
  bool updateShouldNotify(ShellTabIndexScope oldWidget) =>
      index != oldWidget.index;
}
