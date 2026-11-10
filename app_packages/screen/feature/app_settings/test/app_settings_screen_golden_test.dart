import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_app_settings/screen_feature_app_settings.dart';
import 'package:screen_navigation/screen_navigation.dart';

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  void openAppSettings() {}

  @override
  void openDebug() {}

  @override
  void pop() {}

  @override
  void goToHomeTab() {}
}

void main() {
  testWidgets('アプリ設定 / ja / Android / light', (tester) async {
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

    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [screenNavigationProvider.overrideWith((ref) => _Nav())],
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
      await expectLater(
        find.byType(AppSettingsScreen),
        matchesGoldenFile('goldens/app_settings.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
