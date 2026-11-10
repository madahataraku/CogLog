/// OSS ライセンス一覧の表示用。
///
/// Example:
/// ```dart
/// const OssLicensesScreenEntity(packageNames: ['riverpod'], isEmpty: false);
/// ```
final class OssLicensesScreenEntity {
  /// パッケージ名と空フラグを持つ。
  ///
  /// Example:
  /// ```dart
  /// const OssLicensesScreenEntity(packageNames: [], isEmpty: true);
  /// ```
  const OssLicensesScreenEntity({
    required this.packageNames,
    required this.isEmpty,
  });

  /// 一覧に出すパッケージ名。
  final List<String> packageNames;

  /// 空状態メッセージを出すか。
  final bool isEmpty;
}
