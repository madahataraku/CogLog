part of 'advance_tutorial_main_result.dart';

/// メイン完了。
final class AdvanceTutorialMainCompletedResult
    extends AdvanceTutorialMainResult {
  /// [navigation] があれば完了後に View が遷移する。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.completed(
  ///   navigation: AdvanceTutorialMainNavigation.achievements,
  /// );
  /// ```
  const AdvanceTutorialMainCompletedResult({
    this.navigation = AdvanceTutorialMainNavigation.none,
  });

  /// 完了後の遷移先。段階7はアチーブメント。それ以外は none。
  final AdvanceTutorialMainNavigation navigation;
}
