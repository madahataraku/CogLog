import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_app_settings/screen_feature_app_settings.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_app_runtime_info/usecase_load_app_runtime_info.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

final class _RecordingNav implements ScreenNavigation {
  var openDataManagementCalls = 0;

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
  void openDataManagement() {
    openDataManagementCalls += 1;
  }

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

final class _FakeLoadAppRuntimeInfoUsecase
    implements LoadAppRuntimeInfoUsecase {
  @override
  Future<AppRuntimeInfo?> execute() async => const AppRuntimeInfo(
    versionName: '0.1.0',
    buildNumber: '1',
    osName: 'Android',
    osVersion: '14',
  );
}

final class _FakeResetTutorial implements ResetTutorialProgressUsecase {
  @override
  Future<void> execute() async {}
}

void main() {
  test('データ管理ラベルは ja / en で正しい', () async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    expect(
      LocalizeStringDelegate.get(
        'screen_feature_app_settings_data_management_item',
      ),
      'データ管理',
    );
    await LocalizeStringDelegate.resetDelegateForTest();

    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.en,
    );
    expect(
      LocalizeStringDelegate.get(
        'screen_feature_app_settings_data_management_item',
      ),
      'Data management',
    );
    await LocalizeStringDelegate.resetDelegateForTest();
  });

  testWidgets('データ管理項目を表示しタップで遷移ハンドラを呼ぶ', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    tester.platformDispatcher.localesTestValue = const [Locale('ja')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
    addTearDown(LocalizeStringDelegate.resetDelegateForTest);

    final nav = _RecordingNav();
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            screenNavigationProvider.overrideWith((ref) => nav),
            LoadAppRuntimeInfoUsecase.provider.overrideWith(
              (ref) => _FakeLoadAppRuntimeInfoUsecase(),
            ),
            ResetTutorialProgressUsecase.provider.overrideWith(
              (ref) => _FakeResetTutorial(),
            ),
            tutorialRuntimeSessionProvider.overrideWith(
              (ref) => TutorialRuntimeSession(),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const AppSettingsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tile = find.text('データ管理');
      expect(tile, findsOneWidget);

      await tester.tap(tile);
      await tester.pumpAndSettle();

      expect(nav.openDataManagementCalls, 1);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
