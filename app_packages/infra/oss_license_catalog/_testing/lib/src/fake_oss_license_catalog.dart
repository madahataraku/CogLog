import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';

/// 固定一覧または例外を返す。
///
/// Example:
/// ```dart
/// FakeOssLicenseCatalog(entries: const []);
/// ```
final class FakeOssLicenseCatalog implements OssLicenseCatalog {
  /// [entries] か [error] を使う。
  ///
  /// Example:
  /// ```dart
  /// FakeOssLicenseCatalog(error: StateError('x'));
  /// ```
  FakeOssLicenseCatalog({this.entries = const [], this.error});

  /// 成功時の一覧。
  final List<OssLicenseEntry> entries;

  /// 失敗時に投げる値。
  final Object? error;

  /// [error] があれば throwし、なければ [entries] を返す。
  ///
  /// Example:
  /// ```dart
  /// await FakeOssLicenseCatalog().load();
  /// ```
  @override
  Future<List<OssLicenseEntry>> load() async {
    final err = error;
    if (err != null) {
      throw err;
    }
    return entries;
  }
}
