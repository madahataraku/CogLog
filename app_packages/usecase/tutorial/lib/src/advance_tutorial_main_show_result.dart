part of 'advance_tutorial_main_result.dart';

/// 次段階の表示。
final class AdvanceTutorialMainShowResult extends AdvanceTutorialMainResult {
  /// [step] を出し、必要なら [navigation] へ誘導する。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.show(
  ///   step: TutorialMainStep.goalRecommend,
  ///   navigation: AdvanceTutorialMainNavigation.goalSettingsTab,
  /// );
  /// ```
  const AdvanceTutorialMainShowResult({
    required this.step,
    required this.navigation,
  });

  /// 表示する段階。
  final TutorialMainStep step;

  /// 主ボタン後の遷移先。ホーム連鎖中は [AdvanceTutorialMainNavigation.none]。
  final AdvanceTutorialMainNavigation navigation;
}
