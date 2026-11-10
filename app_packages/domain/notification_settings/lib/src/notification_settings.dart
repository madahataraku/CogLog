/// 運動リマインド通知の有効／無効。
///
/// 初期値は無効。OS の端末バックアップ対象に含める。
///
/// Example:
/// ```dart
/// const NotificationSettings(enabled: false);
/// ```
final class NotificationSettings {
  /// [enabled] で通知の可否を持つ。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettings(enabled: true);
  /// ```
  const NotificationSettings({required this.enabled});

  /// 初回の既定値。無効。
  static const initial = NotificationSettings(enabled: false);

  /// 通知が有効か。
  final bool enabled;

  /// [enabled] が同じなら等しい。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettings(enabled: true) ==
  ///     const NotificationSettings(enabled: true);
  /// ```
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationSettings && other.enabled == enabled;

  /// [enabled] に基づくハッシュ。
  @override
  int get hashCode => enabled.hashCode;
}
