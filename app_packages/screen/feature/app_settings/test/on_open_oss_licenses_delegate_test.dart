import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_app_settings/src/viewmodel/delegate/on_open_oss_licenses_delegate.dart';
import 'package:screen_navigation/screen_navigation.dart';

final class _Nav implements ScreenNavigation {
  var openOssLicensesCalls = 0;

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
  void openOssLicenses() {
    openOssLicensesCalls += 1;
  }

  @override
  void openOssLicenseDetail({required String packageName}) {}

  @override
  void pop() {}

  @override
  void goToHomeTab() {}
}

void main() {
  test('openOssLicenses を呼ぶ', () {
    final nav = _Nav();
    OnOpenOssLicensesDelegate(navigation: nav).execute();
    expect(nav.openOssLicensesCalls, 1);
  });
}
