/// アプリ設定の表示用。
///
/// Example:
/// ```dart
/// const AppSettingsScreenEntity(
///   versionText: '0.1.0 (1)',
///   osText: 'Android 14',
/// );
/// ```
final class AppSettingsScreenEntity {
  /// フッターに出す版と OS の文言を持つ。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsScreenEntity(
  ///   versionText: '…',
  ///   osText: '…',
  /// );
  /// ```
  const AppSettingsScreenEntity({
    required this.versionText,
    required this.osText,
  });

  /// バージョン行の値。
  final String versionText;

  /// OS 行の値。
  final String osText;
}
