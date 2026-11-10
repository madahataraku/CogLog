import 'package:riverpod/riverpod.dart';

import 'sync_exercise_reminder_request.dart';
import 'sync_exercise_reminder_result.dart';

/// 設定と履歴からローカル通知を予約または取り消す。
///
/// Example:
/// ```dart
/// usecase.execute(SyncExerciseReminderRequest(now: DateTime.now()));
/// ```
abstract interface class SyncExerciseReminderUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<SyncExerciseReminderUsecase>(
    (ref) => throw UnimplementedError('SyncExerciseReminderUsecase.provider'),
  );

  /// [request.now] を基準に同期する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(SyncExerciseReminderRequest(now: DateTime.now()));
  /// ```
  Future<SyncExerciseReminderResult> execute(
    SyncExerciseReminderRequest request,
  );
}
