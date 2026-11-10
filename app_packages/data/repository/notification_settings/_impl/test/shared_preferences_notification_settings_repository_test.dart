import 'package:data_repository_notification_settings_impl/data_repository_notification_settings_impl.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('キー無しは無効', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesNotificationSettingsRepository(
      preferences,
    );
    expect(await repository.read(), NotificationSettings.initial);
  });

  test('書き込み後に読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesNotificationSettingsRepository(
      preferences,
    );
    await repository.write(const NotificationSettings(enabled: true));
    expect(await repository.read(), const NotificationSettings(enabled: true));
  });
}
