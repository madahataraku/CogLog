import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:usecase_delete_exercise_history/usecase_delete_exercise_history.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

/// 行削除のあとヘルスを試し、失敗しても成功とする。
///
/// Example:
/// ```dart
/// DeleteExerciseHistoryUsecaseImpl(
///   histories: histories,
///   health: health,
///   evaluateAutoUpdate: evaluateAutoUpdate,
///   evaluateAchievements: evaluateAchievements,
///   syncReminder: syncReminder,
/// ).execute(
///   const DeleteExerciseHistoryRequest(
///     id: '11111111-1111-4111-8111-111111111111',
///     healthWorkoutId: null,
///   ),
/// );
/// ```
final class DeleteExerciseHistoryUsecaseImpl
    implements DeleteExerciseHistoryUsecase {
  /// [histories]・[health]・事後フックを使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// DeleteExerciseHistoryUsecaseImpl(
  ///   histories: histories,
  ///   health: health,
  ///   evaluateAutoUpdate: evaluateAutoUpdate,
  ///   evaluateAchievements: evaluateAchievements,
  ///   syncReminder: syncReminder,
  /// );
  /// ```
  const DeleteExerciseHistoryUsecaseImpl({
    required this.histories,
    required this.health,
    required this.evaluateAutoUpdate,
    required this.evaluateAchievements,
    required this.syncReminder,
  });

  /// 運動履歴の保存先。
  final ExerciseHistoryRepository histories;

  /// ヘルスへのサイクリング削除。
  final HealthWorkoutWriter health;

  /// 削除後の目標自動更新。
  final EvaluateDailyGoalAutoUpdateUsecase evaluateAutoUpdate;

  /// 削除後のアチーブメント評価。
  final EvaluateAchievementsUsecase evaluateAchievements;

  /// 削除後のリマインド同期。
  final SyncExerciseReminderUsecase syncReminder;

  /// [request] の行を消し、必要ならヘルスを消し、事後フックを走らせる。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const DeleteExerciseHistoryRequest(
  ///     id: '11111111-1111-4111-8111-111111111111',
  ///     healthWorkoutId: null,
  ///   ),
  /// );
  /// ```
  @override
  Future<DeleteExerciseHistoryResult> execute(
    DeleteExerciseHistoryRequest request,
  ) async {
    try {
      await histories.delete(request.id);

      final healthId = request.healthWorkoutId;
      if (healthId != null) {
        await _deleteHealth(healthId);
      }

      final now = DateTime.now();
      final autoUpdate = await evaluateAutoUpdate.execute(
        EvaluateDailyGoalAutoUpdateRequest(now: now),
      );
      try {
        await syncReminder.execute(SyncExerciseReminderRequest(now: now));
      } on Object {
        // 通知の同期失敗で、削除済みを notFoundOrFailed にしない。
      }

      var newlyUnlocked = const <AchievementUnlock>[];
      try {
        final evaluated = await evaluateAchievements.execute(
          EvaluateAchievementsRequest(now: now, emitNotifications: true),
        );
        newlyUnlocked = evaluated.newlyUnlocked;
      } on Object {
        newlyUnlocked = const [];
      }

      return DeleteExerciseHistoryResult(
        outcome: DeleteExerciseHistoryOutcome.success,
        goalAutoUpdated: autoUpdate.applied,
        newlyUnlockedAchievements: newlyUnlocked,
      );
    } on Object {
      return const DeleteExerciseHistoryResult(
        outcome: DeleteExerciseHistoryOutcome.notFoundOrFailed,
      );
    }
  }

  /// ヘルスを削除し、失敗や例外は握りつぶす。
  ///
  /// Example:
  /// ```dart
  /// await _deleteHealth('health-1');
  /// ```
  Future<void> _deleteHealth(String externalId) async {
    try {
      await health.deleteCycling(externalId: externalId);
    } on Object {
      // ヘルス失敗でも CogLog 側の削除 success を維持する。
    }
  }
}
