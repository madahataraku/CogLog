import 'package:infra_oss_license_catalog/infra_oss_license_catalog.dart';

/// OSS ライセンス一覧の読込結果。
///
/// Example:
/// ```dart
/// OssLicensesScreenState.initial;
/// ```
final class OssLicensesScreenState {
  /// エントリ一覧を持つ。
  ///
  /// Example:
  /// ```dart
  /// const OssLicensesScreenState(entries: []);
  /// ```
  const OssLicensesScreenState({required this.entries});

  /// 未読込の初期状態。
  static const initial = OssLicensesScreenState(entries: []);

  /// 表示するライセンス。
  final List<OssLicenseEntry> entries;
}
