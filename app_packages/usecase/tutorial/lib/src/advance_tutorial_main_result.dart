import 'advance_tutorial_main_navigation.dart';
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
  ///   navigation: AdvanceTutorialMainNavigation.none,
  /// );
  /// ```
  const factory AdvanceTutorialMainResult.show({
    required TutorialMainStep step,
    required AdvanceTutorialMainNavigation navigation,
  }) = AdvanceTutorialMainShowResult;

  /// メイン完了（永続成功または抑止付き完了相当）。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.completed(
  ///   navigation: AdvanceTutorialMainNavigation.achievements,
  /// );
  /// ```
  const factory AdvanceTutorialMainResult.completed({
    AdvanceTutorialMainNavigation navigation,
  }) = AdvanceTutorialMainCompletedResult;

  /// 何もしない。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainResult.noop();
  /// ```
  const factory AdvanceTutorialMainResult.noop() =
      AdvanceTutorialMainNoopResult;
}
