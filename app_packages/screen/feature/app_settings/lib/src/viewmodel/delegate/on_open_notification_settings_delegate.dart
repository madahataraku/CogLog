import 'package:screen_navigation/screen_navigation.dart';

/// 通知設定画面を開く。
///
/// Example:
/// ```dart
/// OnOpenNotificationSettingsDelegate(navigation: navigation).execute();
/// ```
final class OnOpenNotificationSettingsDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenNotificationSettingsDelegate(navigation: navigation);
  /// ```
  const OnOpenNotificationSettingsDelegate({required this.navigation});

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// 通知設定へ遷移する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  void execute() {
    navigation.openNotificationSettings();
  }
}
