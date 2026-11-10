import 'package:infra_app_runtime_info/infra_app_runtime_info.dart';
import 'package:infra_app_runtime_info_testing/infra_app_runtime_info_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_load_app_runtime_info_impl/usecase_load_app_runtime_info_impl.dart';

void main() {
  test('成功時は非 null', () async {
    const info = AppRuntimeInfo(
      versionName: '0.1.0',
      buildNumber: '1',
      osName: 'Android',
    );
    final usecase = LoadAppRuntimeInfoUsecaseImpl(
      reader: FakeAppRuntimeInfoReader(info: info),
    );
    expect(await usecase.execute(), same(info));
  });

  test('失敗時は null', () async {
    final usecase = LoadAppRuntimeInfoUsecaseImpl(
      reader: FakeAppRuntimeInfoReader(error: StateError('x')),
    );
    expect(await usecase.execute(), isNull);
  });
}
