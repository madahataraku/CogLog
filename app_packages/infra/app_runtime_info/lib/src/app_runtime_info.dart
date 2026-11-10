/// 設定画面フッターに出すアプリ実行情報。
///
/// Example:
/// ```dart
/// const AppRuntimeInfo(
///   versionName: '0.1.0',
///   buildNumber: '1',
///   osName: 'Android',
///   osVersion: '14',
/// );
/// ```
final class AppRuntimeInfo {
  /// 成功時は [versionName] / [buildNumber] / [osName] を非空とする。
  ///
  /// Example:
  /// ```dart
  /// const AppRuntimeInfo(
  ///   versionName: '0.1.0',
  ///   buildNumber: '1',
  ///   osName: 'iOS',
  /// );
  /// ```
  const AppRuntimeInfo({
    required this.versionName,
    required this.buildNumber,
    required this.osName,
    this.osVersion,
  });

  /// pubspec 由来の versionName。
  final String versionName;

  /// versionCode / CFBundleVersion。
  final String buildNumber;

  /// Android または iOS。
  final String osName;

  /// 取れたときだけ付く OS 版。
  final String? osVersion;
}
