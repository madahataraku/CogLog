import 'package:screen_navigation/screen_navigation.dart';

/// 前の画面へ戻る。
///
/// Example:
/// ```dart
/// OnBackDelegate(navigation: navigation).execute();
/// ```
final class OnBackDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnBackDelegate(navigation: navigation);
  /// ```
  const OnBackDelegate({required this.navigation});

  /// 画面遷移。
  final ScreenNavigation navigation;

  /// 戻る。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  void execute() {
    navigation.pop();
  }
}
