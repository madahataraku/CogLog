/// 通知設定保存の結果。
///
/// Example:
/// ```dart
/// const SaveNotificationSettingsResult(
///   enabled: true,
///   permissionGranted: false,
/// );
/// ```
final class SaveNotificationSettingsResult {
  /// 保存後の状態。
  ///
  /// Example:
  /// ```dart
  /// const SaveNotificationSettingsResult(
  ///   enabled: true,
  ///   permissionGranted: true,
  /// );
  /// ```
  const SaveNotificationSettingsResult({
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
