import 'package:screen_navigation/screen_navigation.dart';

/// アチーブメント画面を開く。
///
/// Example:
/// ```dart
/// OnOpenAchievementsDelegate(navigation: navigation).execute();
/// ```
final class OnOpenAchievementsDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenAchievementsDelegate(navigation: navigation);
  /// ```
  const OnOpenAchievementsDelegate({required this.navigation});

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// アチーブメントへ遷移する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  void execute() {
    navigation.openAchievements();
  }
}
