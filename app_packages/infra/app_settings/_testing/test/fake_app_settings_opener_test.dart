import 'package:infra_app_settings_testing/infra_app_settings_testing.dart';
import 'package:test/test.dart';

void main() {
  test('openAppSettings で回数を増やす', () async {
    final opener = FakeAppSettingsOpener();
    await opener.openAppSettings();
    await opener.openAppSettings();
    expect(opener.openCallCount, 2);
  });
}
