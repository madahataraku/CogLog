import 'tutorial_main_step.dart';

part 'advance_tutorial_main_completed_result.dart';
part 'advance_tutorial_main_noop_result.dart';
part 'advance_tutorial_main_show_result.dart';

/// メイン導線進行の結果。
///
/// Example:
/// ```dart
/// const AdvanceTutorialMainResult.noop();
/// ```
sealed class AdvanceTutorialMainResult {
  /// 結果の基底。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.completed();
  /// ```
  const AdvanceTutorialMainResult();

  /// 次の段階を表示する。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.show(
  ///   step: TutorialMainStep.homeIntro,
  ///   navigateToGoalTab: false,
  /// );
  /// ```
  const factory AdvanceTutorialMainResult.show({
    required TutorialMainStep step,
    required bool navigateToGoalTab,
  }) = AdvanceTutorialMainShowResult;

  /// メイン完了（永続成功または抑止付き完了相当）。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.completed();
  /// ```
  const factory AdvanceTutorialMainResult.completed() =
      AdvanceTutorialMainCompletedResult;

  /// 何もしない。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.noop();
  /// ```
  const factory AdvanceTutorialMainResult.noop() =
      AdvanceTutorialMainNoopResult;
}
