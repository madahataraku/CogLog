/// 通知設定画面の内部状態。
///
/// Example:
/// ```dart
/// NotificationSettingsScreenState.initial;
/// ```
final class NotificationSettingsScreenState {
  /// 読み込み結果を持つ。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettingsScreenState(
  ///   enabled: false,
  ///   permissionGranted: false,
  ///   loaded: true,
  /// );
  /// ```
  const NotificationSettingsScreenState({
    required this.enabled,
    required this.permissionGranted,
    required this.loaded,
  });

  /// 初期（未読込）。
  static const initial = NotificationSettingsScreenState(
    enabled: false,
    permissionGranted: false,
    loaded: false,
  );

  /// 通知 ON/OFF。
  final bool enabled;

  /// OS 許可。
  final bool permissionGranted;

  /// 初回読み込み済みか。
  final bool loaded;

  /// 案内を出すか。
  bool get showPermissionGuidance => enabled && !permissionGranted;
}
