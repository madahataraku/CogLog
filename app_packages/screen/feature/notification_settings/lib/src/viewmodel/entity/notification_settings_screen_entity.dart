/// 通知設定画面の表示用。
///
/// Example:
/// ```dart
/// const NotificationSettingsScreenEntity(
///   enabled: false,
///   showPermissionGuidance: false,
/// );
/// ```
final class NotificationSettingsScreenEntity {
  /// 表示に必要な値。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettingsScreenEntity(
  ///   enabled: true,
  ///   showPermissionGuidance: true,
  /// );
  /// ```
  const NotificationSettingsScreenEntity({
    required this.enabled,
    required this.showPermissionGuidance,
  });

  /// スイッチ状態。
  final bool enabled;

  /// 許可案内の表示。
  final bool showPermissionGuidance;
}
