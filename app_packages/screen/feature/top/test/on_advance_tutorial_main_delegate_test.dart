import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_top/src/viewmodel/delegate/on_advance_tutorial_main_delegate.dart';
import 'package:screen_feature_top/src/viewmodel/state/top_screen_state.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

final class _Advance implements AdvanceTutorialMainUsecase {
  _Advance(this.result);

  final AdvanceTutorialMainResult result;

  @override
  Future<AdvanceTutorialMainResult> execute(
    AdvanceTutorialMainRequest request,
  ) async {
    return result;
  }
}

final class _Navigation implements ScreenNavigation {
  var goalTabCalls = 0;

  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  Future<ExerciseHistoryEditPopResult?> openExerciseHistoryEditAndWait({
    required String id,
  }) async => null;

  @override
  void openAppSettings() {}

  @override
  Future<void> openAchievements() async {}

  @override
  void openDebug() {}

  @override
  void openNotificationSettings() {}

  @override
  void openDataManagement() {}

  @override
  void openOssLicenses() {}

  @override
  void openOssLicenseDetail({required String packageName}) {}

  @override
  void pop() {}

  @override
  void popWithResult<T extends Object?>(T result) {}

  @override
  void goToHomeTab() {}

  @override
  void goToGoalSettingsTab() {
    goalTabCalls += 1;
  }

  @override
  void goToMeterCaptureTab() {}
}

TopScreenState _baseState({
  bool pendingTutorialMain = false,
  TutorialMainStep? tutorialMainStep,
}) {
  return TopScreenState(
    loaded: true,
    metric: PeriodTotalMetric.calories,
    today: PeriodAggregate.empty,
    week: PeriodAggregate.empty,
    month: PeriodAggregate.empty,
    goal: DailyGoal.unset,
    adviceText: '',
    adviceTone: AdviceTone.fun,
    pendingModelDownloadGuidance: false,
    pendingGemmaMeterGuidance: false,
    pendingTutorialMain: pendingTutorialMain,
    tutorialMainStep: tutorialMainStep,
    pendingTutorialAchievement: false,
    hasNewAchievements: false,
    weeklyAchievementDays: null,
    weekGoalAchievementDayCount: 0,
    showWeeklyGoalGuidance: false,
  );
}

void main() {
  test('ホーム上の次段階は pending を立てず step だけ更新する', () async {
    final state = MutableStateStream(
      _baseState(
        pendingTutorialMain: false,
        tutorialMainStep: TutorialMainStep.homeIntro,
      ),
    );
    final navigation = _Navigation();
    await OnAdvanceTutorialMainDelegate(
      state: state,
      advanceUsecase: _Advance(
        const AdvanceTutorialMainResult.show(
          step: TutorialMainStep.goalProgressIntro,
          navigateToGoalTab: false,
        ),
      ),
      navigation: navigation,
    ).execute(const AdvanceTutorialMainRequest.next());

    expect(state.state.pendingTutorialMain, isFalse);
    expect(state.state.tutorialMainStep, TutorialMainStep.goalProgressIntro);
    expect(navigation.goalTabCalls, 0);
  });

  test('目標タブ誘導時は pending を下ろし step を消す', () async {
    final state = MutableStateStream(
      _baseState(tutorialMainStep: TutorialMainStep.goalRecommend),
    );
    final navigation = _Navigation();
    await OnAdvanceTutorialMainDelegate(
      state: state,
      advanceUsecase: _Advance(
        const AdvanceTutorialMainResult.show(
          step: TutorialMainStep.goalRecommend,
          navigateToGoalTab: true,
        ),
      ),
      navigation: navigation,
    ).execute(const AdvanceTutorialMainRequest.next());

    expect(state.state.pendingTutorialMain, isFalse);
    expect(state.state.tutorialMainStep, isNull);
    expect(navigation.goalTabCalls, 1);
  });
}
