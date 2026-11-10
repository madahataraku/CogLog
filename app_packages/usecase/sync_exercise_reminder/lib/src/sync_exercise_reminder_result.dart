/// リマインド同期の結果。
///
/// Example:
/// ```dart
/// const SyncExerciseReminderResult(scheduled: false);
/// ```
final class SyncExerciseReminderResult {
  /// [scheduled] が true なら予約した。
  ///
  /// Example:
  /// ```dart
  /// const SyncExerciseReminderResult(scheduled: true);
  /// ```
  const SyncExerciseReminderResult({required this.scheduled});

  /// 通知を予約したか。
  final bool scheduled;
}
