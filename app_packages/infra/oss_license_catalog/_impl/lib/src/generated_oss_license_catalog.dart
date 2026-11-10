import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';

import '../gen/oss_licenses.dart';
import 'extra_oss_licenses.dart';

/// 生成物と [extraOssLicenses] を束ねる。
///
/// Example:
/// ```dart
/// const GeneratedOssLicenseCatalog();
/// ```
final class GeneratedOssLicenseCatalog implements OssLicenseCatalog {
  /// 生成カタログを作る。
  ///
  /// Example:
  /// ```dart
  /// const GeneratedOssLicenseCatalog();
  /// ```
  const GeneratedOssLicenseCatalog();

  static const _excluded = {'app', 'app_runner'};

  /// 生成一覧をマージして name 順に返す。失敗時は空。
  ///
  /// Example:
  /// ```dart
  /// await const GeneratedOssLicenseCatalog().load();
  /// ```
  @override
  Future<List<OssLicenseEntry>> load() async {
    try {
      final generated = allDependencies
          .where((p) => !_excluded.contains(p.name))
          .map((p) => OssLicenseEntry(name: p.name, license: p.license ?? ''))
          .where((e) => e.license.isNotEmpty);
      final merged = [...generated, ...extraOssLicenses];
      merged.sort((a, b) => a.name.compareTo(b.name));
      return merged;
    } catch (_) {
      return const [];
    }
  }
}
