import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_data_management/src/viewmodel/delegate/on_back_delegate.dart';
import 'package:screen_navigation/screen_navigation.dart';

final class _Nav implements ScreenNavigation {
  var popCalls = 0;

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
  void pop() {
    popCalls += 1;
  }

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

void main() {
  test('pop を呼ぶ', () {
    final nav = _Nav();
    OnBackDelegate(navigation: nav).execute();
    expect(nav.popCalls, 1);
  });
}
