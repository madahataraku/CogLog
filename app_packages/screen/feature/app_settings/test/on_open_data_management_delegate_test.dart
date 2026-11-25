import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_app_settings/src/viewmodel/delegate/on_open_data_management_delegate.dart';
import 'package:screen_navigation/screen_navigation.dart';

final class _Nav implements ScreenNavigation {
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
}

void main() {
  test('openDataManagement を呼ぶ', () {
    final nav = _Nav();
    OnOpenDataManagementDelegate(navigation: nav).execute();
    expect(nav.openDataManagementCalls, 1);
  });
}
