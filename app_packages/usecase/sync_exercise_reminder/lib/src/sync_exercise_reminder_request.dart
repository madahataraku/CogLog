/// リマインド同期の入力。
///
/// Example:
/// ```dart
/// SyncExerciseReminderRequest(now: DateTime.now());
/// ```
final class SyncExerciseReminderRequest {
  /// [now] を基準に予定を計算する。
  ///
  /// Example:
  /// ```dart
  /// SyncExerciseReminderRequest(now: DateTime.now());
  /// ```
  const SyncExerciseReminderRequest({required this.now});

  /// 現在時刻。
  final DateTime now;
}
