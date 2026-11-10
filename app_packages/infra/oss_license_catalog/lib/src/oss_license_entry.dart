/// 1 ライブラリ分のライセンス。
///
/// Example:
/// ```dart
/// const OssLicenseEntry(name: 'riverpod', license: 'MIT');
/// ```
final class OssLicenseEntry {
  /// 名称と本文で作る。
  ///
  /// Example:
  /// ```dart
  /// const OssLicenseEntry(name: 'riverpod', license: 'MIT');
  /// ```
  const OssLicenseEntry({required this.name, required this.license});

  /// パッケージ名。
  final String name;

  /// ライセンス本文。
  final String license;
}
