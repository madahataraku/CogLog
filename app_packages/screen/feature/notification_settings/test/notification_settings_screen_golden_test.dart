import 'package:data_repository_notification_settings_testing/data_repository_notification_settings_testing.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infra_local_notification_testing/infra_local_notification_testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_notification_settings/screen_feature_notification_settings.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_notification_settings/usecase_load_notification_settings.dart';
import 'package:usecase_load_notification_settings_impl/usecase_load_notification_settings_impl.dart';
import 'package:usecase_save_notification_settings/usecase_save_notification_settings.dart';
import 'package:usecase_save_notification_settings_impl/usecase_save_notification_settings_impl.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  void openAppSettings() {}

  @override
  void openAchievements() {}

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
  void goToHomeTab() {}
}

final class _NoopSync implements SyncExerciseReminderUsecase {
  @override
  Future<SyncExerciseReminderResult> execute(
    SyncExerciseReminderRequest request,
  ) async => const SyncExerciseReminderResult(scheduled: false);
}

Future<void> _pump({
  required WidgetTester tester,
  required bool enabled,
  required bool permissionGranted,
  required String golden,
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

  final settings = MemoryNotificationSettingsRepository();
  await settings.write(NotificationSettings(enabled: enabled));
  final notifications = FakeLocalNotificationGateway(
    permissionGranted: permissionGranted,
  );

  try {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          screenNavigationProvider.overrideWith((ref) => _Nav()),
          LoadNotificationSettingsUsecase.provider.overrideWith(
            (ref) => LoadNotificationSettingsUsecaseImpl(
              settings: settings,
              notifications: notifications,
            ),
          ),
          SaveNotificationSettingsUsecase.provider.overrideWith(
            (ref) => SaveNotificationSettingsUsecaseImpl(
              settings: settings,
              notifications: notifications,
              sync: _NoopSync(),
            ),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('ja'),
          home: FTheme(
            data: FThemeData(touch: true, colors: FColors.neutralLight),
            child: const NotificationSettingsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(NotificationSettingsScreen),
      matchesGoldenFile(golden),
    );
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  testWidgets('通知設定 OFF', (tester) async {
    await _pump(
      tester: tester,
      enabled: false,
      permissionGranted: false,
      golden: 'goldens/notification_settings_off.png',
    );
  });

  testWidgets('通知設定 ON 許可あり', (tester) async {
    await _pump(
      tester: tester,
      enabled: true,
      permissionGranted: true,
      golden: 'goldens/notification_settings_on.png',
    );
  });

  testWidgets('通知設定 ON 許可なし', (tester) async {
    await _pump(
      tester: tester,
      enabled: true,
      permissionGranted: false,
      golden: 'goldens/notification_settings_denied.png',
    );
  });
}
