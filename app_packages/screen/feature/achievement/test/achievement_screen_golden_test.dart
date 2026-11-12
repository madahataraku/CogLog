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
  void openOssLicenses() {}

  @override
  void openOssLicenseDetail({required String packageName}) {}

  @override
  void pop() {}

  @override
  void popWithResult<T extends Object?>(T result) {}

  @override
  void goToHomeTab() {}
}

final class _FakeMark implements MarkAchievementsViewedUsecase {
  @override
  Future<void> execute(MarkAchievementsViewedRequest request) async {}
}

final class _FakeLoad implements LoadAchievementsUsecase {
  _FakeLoad(this.result);

  final LoadAchievementsResult result;

  @override
  Future<LoadAchievementsResult> execute(
    LoadAchievementsRequest request,
  ) async => result;
}

const _mixedRows = [
  AchievementRow(
    id: 'first_record',
    unlocked: true,
    current: 1,
    target: 1,
    progressRatio: 1,
    binaryProgress: true,
    isNew: true,
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
  AchievementRow(
    id: 'distance_1',
    unlocked: false,
    current: 0.4,
    target: 1,
    progressRatio: 0.4,
    binaryProgress: false,
    isNew: false,
  ),
];

const _allUnlockedRows = [
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
    unlocked: true,
    current: 3,
    target: 3,
    progressRatio: 1,
    binaryProgress: false,
    isNew: false,
  ),
  AchievementRow(
    id: 'calories_50',
    unlocked: true,
    current: 50,
    target: 50,
    progressRatio: 1,
    binaryProgress: false,
    isNew: false,
  ),
];

Future<void> _pumpAchievement(
  WidgetTester tester, {
  required LoadAchievementsResult result,
}) async {
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

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        screenNavigationProvider.overrideWith((ref) => _Nav()),
        LoadAchievementsUsecase.provider.overrideWith(
          (ref) => _FakeLoad(result),
        ),
        MarkAchievementsViewedUsecase.provider.overrideWith(
          (ref) => _FakeMark(),
        ),
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
}

void main() {
  testWidgets('アチーブメント 混在 / ja / Android / light', (tester) async {
    try {
      await _pumpAchievement(
        tester,
        result: const LoadAchievementsSuccess(_mixedRows),
      );
      await expectLater(
        find.byType(AchievementScreen),
        matchesGoldenFile('goldens/achievement_mixed.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('アチーブメント 全開放 / ja / Android / light', (tester) async {
    try {
      await _pumpAchievement(
        tester,
        result: const LoadAchievementsSuccess(_allUnlockedRows),
      );
      await expectLater(
        find.byType(AchievementScreen),
        matchesGoldenFile('goldens/achievement_all_unlocked.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('アチーブメント 失敗 / ja / Android / light', (tester) async {
    try {
      await _pumpAchievement(tester, result: const LoadAchievementsFailed());
      await expectLater(
        find.byType(AchievementScreen),
        matchesGoldenFile('goldens/achievement_failed.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
