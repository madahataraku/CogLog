import 'package:riverpod/riverpod.dart';

import 'oss_license_entry.dart';

/// OSS ライセンス一覧の読み出し口。
///
/// Example:
/// ```dart
/// OssLicenseCatalog.provider;
/// ```
abstract interface class OssLicenseCatalog {
  /// 未接続時は失敗する注入点。
  static final provider = Provider<OssLicenseCatalog>(
    (ref) => throw UnimplementedError('OssLicenseCatalog.provider'),
  );

  /// 失敗しても空 list を返す。
  ///
  /// Example:
  /// ```dart
  /// await catalog.load();
  /// ```
  Future<List<OssLicenseEntry>> load();
}
