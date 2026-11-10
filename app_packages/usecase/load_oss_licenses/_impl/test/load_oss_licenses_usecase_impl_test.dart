import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';
import 'package:infra_oss_license_catalog_testing/infra_oss_license_catalog_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_load_oss_licenses_impl/usecase_load_oss_licenses_impl.dart';

void main() {
  test('成功時は一覧を返す', () async {
    const entries = [OssLicenseEntry(name: 'a', license: 'MIT')];
    final usecase = LoadOssLicensesUsecaseImpl(
      catalog: FakeOssLicenseCatalog(entries: entries),
    );
    expect(await usecase.execute(), entries);
  });

  test('失敗時は空 list', () async {
    final usecase = LoadOssLicensesUsecaseImpl(
      catalog: FakeOssLicenseCatalog(error: StateError('x')),
    );
    expect(await usecase.execute(), isEmpty);
  });
}
