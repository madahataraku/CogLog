import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_goal_settings/screen_feature_goal_settings.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';
import 'package:usecase_load_daily_goal_impl/usecase_load_daily_goal_impl.dart';
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';
import 'package:usecase_save_daily_goal_impl/usecase_save_daily_goal_impl.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

final class _Nav implements ScreenNavigation {
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
  void goToGoalSettingsTab() {}

  @override
  void goToMeterCaptureTab() {}

  @override
  void goToTrendsTab() {}

  @override
  void goToExerciseHistoryTab() {}
}

final class _AdvanceTutorial implements AdvanceTutorialMainUsecase {
  @override
  Future<AdvanceTutorialMainResult> execute(
    AdvanceTutorialMainRequest request,
  ) async {
    return const AdvanceTutorialMainResult.noop();
  }
}

final class _EvaluateTutorialNever implements EvaluateTutorialContextUsecase {
  @override
  Future<EvaluateTutorialContextResult> execute(
    EvaluateTutorialContextRequest request,
  ) async => const EvaluateTutorialContextResult(shouldShow: false);
}

final class _MarkTutorialNever implements MarkTutorialContextSeenUsecase {
  @override
  Future<void> execute(MarkTutorialContextSeenRequest request) async {}
}

void main() {
  testWidgets('目標設定の未設定空状態 / ja / Android / light', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    addTearDown(LocalizeStringDelegate.resetDelegateForTest);

    final goals = MemoryDailyGoalRepository();

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            LoadDailyGoalUsecase.provider.overrideWith(
              (ref) => LoadDailyGoalUsecaseImpl(goals: goals),
            ),
            SaveDailyGoalUsecase.provider.overrideWith(
              (ref) => SaveDailyGoalUsecaseImpl(goals: goals),
            ),
            AdvanceTutorialMainUsecase.provider.overrideWith(
              (ref) => _AdvanceTutorial(),
            ),
            EvaluateTutorialContextUsecase.provider.overrideWith(
              (ref) => _EvaluateTutorialNever(),
            ),
            MarkTutorialContextSeenUsecase.provider.overrideWith(
              (ref) => _MarkTutorialNever(),
            ),
            tutorialRuntimeSessionProvider.overrideWith(
              (ref) => TutorialRuntimeSession(),
            ),
            CoachMarkProviders.registry.overrideWith(
              (ref) => CoachMarkRegistry(),
            ),
            screenNavigationProvider.overrideWith((ref) => _Nav()),
          ],
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const GoalSettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(GoalSettingsScreen),
        matchesGoldenFile('goldens/goal_settings_unset.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
