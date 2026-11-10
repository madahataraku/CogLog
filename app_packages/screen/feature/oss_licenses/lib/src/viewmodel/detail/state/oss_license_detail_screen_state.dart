/// OSS ライセンス詳細の読込結果。
///
/// Example:
/// ```dart
/// OssLicenseDetailScreenState.initial(packageName: 'riverpod');
/// ```
final class OssLicenseDetailScreenState {
  /// 対象名と本文を持つ。
  ///
  /// Example:
  /// ```dart
  /// const OssLicenseDetailScreenState(
  ///   packageName: 'riverpod',
  ///   licenseText: 'MIT',
  /// );
  /// ```
  const OssLicenseDetailScreenState({
    required this.packageName,
    required this.licenseText,
  });

  /// まだ本文を読んでいない状態。
  ///
  /// Example:
  /// ```dart
  /// OssLicenseDetailScreenState.initial(packageName: 'riverpod');
  /// ```
  factory OssLicenseDetailScreenState.initial({required String packageName}) =>
      OssLicenseDetailScreenState(packageName: packageName, licenseText: null);

  /// 対象のパッケージ名。
  final String packageName;

  /// ライセンス本文。未読込・不在は null。
  final String? licenseText;
}
