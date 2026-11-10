import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_app_settings/src/viewmodel/delegate/app_settings_state_to_entity_delegate.dart';
import 'package:screen_feature_app_settings/src/viewmodel/state/app_settings_screen_state.dart';

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  test('読込中は両方 info_loading', () {
    final entity = const AppSettingsStateToEntityDelegate().execute(
      AppSettingsScreenState.initial,
    );
    expect(entity.versionText, '…');
    expect(entity.osText, '…');
  });

  test('info が null なら両方 info_unavailable', () {
    final entity = const AppSettingsStateToEntityDelegate().execute(
      const AppSettingsScreenState(loading: false),
    );
    expect(entity.versionText, '—');
    expect(entity.osText, '—');
  });

  test('版と OS を整形する', () {
    final entity = const AppSettingsStateToEntityDelegate().execute(
      const AppSettingsScreenState(
        loading: false,
        info: AppRuntimeInfo(
          versionName: '0.1.0',
          buildNumber: '42',
          osName: 'Android',
          osVersion: '14',
        ),
      ),
    );
    expect(entity.versionText, '0.1.0 (42)');
    expect(entity.osText, 'Android 14');
  });

  test('OS 版が無いときは名前だけ', () {
    final entity = const AppSettingsStateToEntityDelegate().execute(
      const AppSettingsScreenState(
        loading: false,
        info: AppRuntimeInfo(
          versionName: '1.0.0',
          buildNumber: '1',
          osName: 'iOS',
        ),
      ),
    );
    expect(entity.versionText, '1.0.0 (1)');
    expect(entity.osText, 'iOS');
  });
}
