/// 通知設定画面の表示用。
///
/// Example:
/// ```dart
/// const NotificationSettingsScreenEntity(
///   enabled: false,
///   showPermissionGuidance: false,
///   loaded: false,
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
  ///   loaded: true,
  /// );
  /// ```
  const NotificationSettingsScreenEntity({
    required this.enabled,
    required this.showPermissionGuidance,
    required this.loaded,
  });

  /// スイッチ状態。
  final bool enabled;

  /// 許可案内の表示。
  final bool showPermissionGuidance;

  /// 初回読み込み済みか。
  final bool loaded;
}
