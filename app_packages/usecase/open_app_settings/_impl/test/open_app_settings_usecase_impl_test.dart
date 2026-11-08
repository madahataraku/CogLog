import 'package:infra_app_settings_testing/infra_app_settings_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_open_app_settings_impl/usecase_open_app_settings_impl.dart';

void main() {
  test('opener を 1 回呼ぶ', () async {
    final opener = FakeAppSettingsOpener();

    await OpenAppSettingsUsecaseImpl(opener: opener).execute();

    expect(opener.openCallCount, 1);
  });
}
