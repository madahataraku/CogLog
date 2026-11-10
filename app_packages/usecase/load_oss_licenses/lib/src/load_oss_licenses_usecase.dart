import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';
import 'package:riverpod/riverpod.dart';

/// OSS ライセンス一覧を画面向けに読む。
///
/// Example:
/// ```dart
/// LoadOssLicensesUsecase.provider;
/// ```
abstract interface class LoadOssLicensesUsecase {
  /// 未接続時は失敗する注入点。
  static final provider = Provider<LoadOssLicensesUsecase>(
    (ref) => throw UnimplementedError('LoadOssLicensesUsecase.provider'),
  );

  /// 失敗時は空 list。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<List<OssLicenseEntry>> execute();
}
