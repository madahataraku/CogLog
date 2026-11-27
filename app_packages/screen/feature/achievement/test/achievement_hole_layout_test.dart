import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_achievement/screen_feature_achievement.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

final class _EvaluateNever implements EvaluateTutorialContextUsecase {
  @override
  Future<EvaluateTutorialContextResult> execute(
    EvaluateTutorialContextRequest request,
  ) async => const EvaluateTutorialContextResult(shouldShow: false);
}

final class _MarkNever implements MarkTutorialContextSeenUsecase {
  @override
  Future<void> execute(MarkTutorialContextSeenRequest request) async {}
}

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

final class _FakeMarkViewed implements MarkAchievementsViewedUsecase {
  @override
  Future<void> execute(MarkAchievementsViewedRequest request) async {}
}

final class _FakeLoad implements LoadAchievementsUsecase {
  @override
  Future<LoadAchievementsResult> execute(
    LoadAchievementsRequest request,
  ) async => const LoadAchievementsSuccess([
    AchievementRow(
      id: 'first_record',
      unlocked: true,
      current: 1,
      target: 1,
      progressRatio: 1,
      binaryProgress: true,
      isNew: false,
    ),
    AchievementRow(
      id: 'streak_3',
      unlocked: false,
      current: 1,
      target: 3,
      progressRatio: 1 / 3,
      binaryProgress: false,
      isNew: false,
    ),
  ]);
}

void main() {
  // テスト対象:
  // AchievementScreenBody の achievementList 穴
  //
  // テスト内容:
  // 穴矩形は先頭行の枠と一致し、一覧の水平・先頭上 inset（16 / 8）を含まない。
  testWidgets('先頭行の穴は一覧 inset の外側にあり枠だけを指す', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    addTearDown(LocalizeStringDelegate.resetDelegateForTest);

    final registry = CoachMarkRegistry();
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            screenNavigationProvider.overrideWith((ref) => _Nav()),
            LoadAchievementsUsecase.provider.overrideWith((ref) => _FakeLoad()),
            MarkAchievementsViewedUsecase.provider.overrideWith(
              (ref) => _FakeMarkViewed(),
            ),
            EvaluateTutorialContextUsecase.provider.overrideWith(
              (ref) => _EvaluateNever(),
            ),
            MarkTutorialContextSeenUsecase.provider.overrideWith(
              (ref) => _MarkNever(),
            ),
            tutorialRuntimeSessionProvider.overrideWith(
              (ref) => TutorialRuntimeSession(),
            ),
            CoachMarkProviders.registry.overrideWith((ref) => registry),
          ],
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const AchievementScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final hole = registry.rectFor(
        CoachMarkTargetId.achievementList,
        tester.element(find.byType(AchievementScreen)),
      );
      expect(hole, isNotNull);

      final list = find.byType(ListView);
      expect(list, findsOneWidget);
      final listRect = tester.getRect(list);

      // 水平 16・先頭上 8 の inset は穴の外。
      expect(hole!.left, closeTo(listRect.left + 16, 0.5));
      expect(hole.right, closeTo(listRect.right - 16, 0.5));
      expect(hole.top, closeTo(listRect.top + 8, 0.5));

      final firstDecorated = find.descendant(
        of: list,
        matching: find.byType(DecoratedBox),
      );
      expect(firstDecorated, findsWidgets);
      final rowRect = tester.getRect(firstDecorated.first);
      expect(hole, rowRect);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
