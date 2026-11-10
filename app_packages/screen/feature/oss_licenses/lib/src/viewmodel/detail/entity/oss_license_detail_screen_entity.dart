/// OSS ライセンス詳細の表示用。
///
/// Example:
/// ```dart
/// const OssLicenseDetailScreenEntity(
///   licenseText: 'MIT',
///   isEmpty: false,
/// );
/// ```
final class OssLicenseDetailScreenEntity {
  /// 本文と空フラグを持つ。
  ///
  /// Example:
  /// ```dart
  /// const OssLicenseDetailScreenEntity(licenseText: '', isEmpty: true);
  /// ```
  const OssLicenseDetailScreenEntity({
    required this.licenseText,
    required this.isEmpty,
  });

  /// 表示するライセンス本文。空のときは空文字。
  final String licenseText;

  /// 空状態メッセージを出すか。
  final bool isEmpty;
}
