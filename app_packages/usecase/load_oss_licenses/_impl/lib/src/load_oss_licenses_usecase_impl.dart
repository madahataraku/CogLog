import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';
import 'package:usecase_load_oss_licenses/usecase_load_oss_licenses.dart';

/// [OssLicenseCatalog] を呼ぶ実装。
///
/// Example:
/// ```dart
/// LoadOssLicensesUsecaseImpl(catalog: catalog);
/// ```
final class LoadOssLicensesUsecaseImpl implements LoadOssLicensesUsecase {
  /// [catalog] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadOssLicensesUsecaseImpl(catalog: catalog);
  /// ```
  const LoadOssLicensesUsecaseImpl({required this.catalog});

  /// ライセンス一覧の読み出し口。
  final OssLicenseCatalog catalog;

  /// 例外時は空 list。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<List<OssLicenseEntry>> execute() async {
    try {
      return await catalog.load();
    } catch (_) {
      return const [];
    }
  }
}
