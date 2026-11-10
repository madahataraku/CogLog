import 'package:screen_navigation/screen_navigation.dart';

/// アプリ設定を開く。
///
/// Example:
/// ```dart
/// OnOpenAppSettingsDelegate(navigation: navigation).execute();
/// ```
final class OnOpenAppSettingsDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenAppSettingsDelegate(navigation: navigation);
  /// ```
  const OnOpenAppSettingsDelegate({required this.navigation});

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// アプリ設定へ遷移する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  void execute() {
    navigation.openAppSettings();
  }
}
