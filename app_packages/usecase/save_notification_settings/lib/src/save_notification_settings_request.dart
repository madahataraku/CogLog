/// 通知設定保存の入力。
///
/// Example:
/// ```dart
/// const SaveNotificationSettingsRequest(enabled: true);
/// ```
final class SaveNotificationSettingsRequest {
  /// [enabled] を保存する。
  ///
  /// Example:
  /// ```dart
  /// const SaveNotificationSettingsRequest(enabled: false);
  /// ```
  const SaveNotificationSettingsRequest({required this.enabled, this.now});

  /// 保存する ON/OFF。
  final bool enabled;

  /// 同期に使う現在時刻。null なら実行時の現在時刻。
  final DateTime? now;
}
