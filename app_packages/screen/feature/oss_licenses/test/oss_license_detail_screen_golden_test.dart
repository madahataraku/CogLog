import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_oss_licenses/screen_feature_oss_licenses.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_oss_licenses/usecase_load_oss_licenses.dart';

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

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
  void goToHomeTab() {}
}

final class _FakeLoadOssLicensesUsecase implements LoadOssLicensesUsecase {
  _FakeLoadOssLicensesUsecase(this.entries);

  final List<OssLicenseEntry> entries;

  @override
  Future<List<OssLicenseEntry>> execute() async => entries;
}

void main() {
  testWidgets('ライセンス詳細 / ja / Android / light', (tester) async {
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
          overrides: [
            screenNavigationProvider.overrideWith((ref) => _Nav()),
            LoadOssLicensesUsecase.provider.overrideWith(
              (ref) => _FakeLoadOssLicensesUsecase(const [
                OssLicenseEntry(
                  name: 'riverpod',
                  license: 'Permission is hereby granted...',
                ),
                OssLicenseEntry(name: 'forui', license: 'MIT'),
              ]),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('ja'),
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: const OssLicenseDetailScreen(packageName: 'riverpod'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(OssLicenseDetailScreen),
        matchesGoldenFile('goldens/oss_license_detail.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
