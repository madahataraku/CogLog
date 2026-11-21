/// `.cogsav` が壊れているか、許可されないパスを含む。
///
/// Example:
/// ```dart
/// throw const CogsavCorruptException('manifest.json が無い');
/// ```
final class CogsavCorruptException implements Exception {
  /// [message] で失敗理由を残す。
  ///
  /// Example:
  /// ```dart
  /// const CogsavCorruptException('data.json が無い');
  /// ```
  const CogsavCorruptException(this.message);

  /// 人が読む短い理由。
  final String message;

  @override
  String toString() => 'CogsavCorruptException: $message';
}

/// `.cogsav` の formatVersion がこのアプリ非対応。
///
/// Example:
/// ```dart
/// throw const CogsavUnsupportedVersionException(2);
/// ```
final class CogsavUnsupportedVersionException implements Exception {
  /// 見つかった [formatVersion] を残す。
  ///
  /// Example:
  /// ```dart
  /// const CogsavUnsupportedVersionException(99);
  /// ```
  const CogsavUnsupportedVersionException(this.formatVersion);

  /// アーカイブに書かれていた版。
  final int formatVersion;

  @override
  String toString() =>
      'CogsavUnsupportedVersionException: formatVersion=$formatVersion';
}
