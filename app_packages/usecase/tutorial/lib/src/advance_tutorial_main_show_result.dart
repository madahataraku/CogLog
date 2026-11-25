part of 'advance_tutorial_main_result.dart';

/// 次段階の表示。
final class AdvanceTutorialMainShowResult extends AdvanceTutorialMainResult {
  /// [step] を出し、必要なら目標タブへ誘導する。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.show(
  ///   step: TutorialMainStep.goalRecommend,
  ///   navigateToGoalTab: true,
  /// );
  /// ```
  const AdvanceTutorialMainShowResult({
    required this.step,
    required this.navigateToGoalTab,
  });

  /// 表示する段階。
  final TutorialMainStep step;

  /// true なら目標設定タブへ切り替える。
  final bool navigateToGoalTab;
}
