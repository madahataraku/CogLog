import 'package:screen_navigation/screen_navigation.dart';

/// デバッグ画面を開く。
///
/// Example:
/// ```dart
/// OnOpenDebugDelegate(navigation: navigation).execute();
/// ```
final class OnOpenDebugDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenDebugDelegate(navigation: navigation);
  /// ```
  const OnOpenDebugDelegate({required this.navigation});

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// デバッグへ遷移する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  void execute() {
    navigation.openDebug();
  }
}
