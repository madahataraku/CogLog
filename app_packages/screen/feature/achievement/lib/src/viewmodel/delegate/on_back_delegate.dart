import 'package:screen_navigation/screen_navigation.dart';

/// アチーブメントから 1 つ戻る。
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

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// スタックを 1 つ戻す。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  void execute() {
    navigation.pop();
  }
}
