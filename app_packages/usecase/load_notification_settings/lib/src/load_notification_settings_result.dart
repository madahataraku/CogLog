/// 通知設定と許可状態。
///
/// Example:
/// ```dart
/// const LoadNotificationSettingsResult(
///   enabled: false,
///   permissionGranted: false,
/// );
/// ```
final class LoadNotificationSettingsResult {
  /// [enabled] と [permissionGranted] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const LoadNotificationSettingsResult(
  ///   enabled: true,
  ///   permissionGranted: false,
  /// );
  /// ```
  const LoadNotificationSettingsResult({
    required this.enabled,
    required this.permissionGranted,
  });

  /// アプリ内の通知 ON/OFF。
  final bool enabled;

  /// OS の通知許可があるか。
  final bool permissionGranted;

  /// 許可拒否の案内を出すか。
  bool get showPermissionGuidance => enabled && !permissionGranted;
}
