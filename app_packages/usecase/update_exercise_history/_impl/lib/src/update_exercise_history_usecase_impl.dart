import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';
import 'package:usecase_update_exercise_history/usecase_update_exercise_history.dart';

/// 登録可能条件を満たすときだけ更新し、ヘルス失敗でも成功とする。
///
/// Example:
/// ```dart
/// UpdateExerciseHistoryUsecaseImpl(
///   histories: histories,
///   health: health,
///   evaluateAutoUpdate: evaluateAutoUpdate,
///   evaluateAchievements: evaluateAchievements,
///   syncReminder: syncReminder,
/// ).execute(
///   UpdateExerciseHistoryRequest(
///     id: '11111111-1111-4111-8111-111111111111',
///     creationStartedAt: DateTime.timestamp(),
///     capturedAt: DateTime.timestamp(),
///     recordedAt: DateTime.timestamp(),
///     distanceKm: 1,
///     duration: const Duration(minutes: 1),
///     caloriesKcal: 1,
///     previousHealthWorkoutId: null,
///   ),
/// );
/// ```
final class UpdateExerciseHistoryUsecaseImpl
    implements UpdateExerciseHistoryUsecase {
  /// [histories]・[health]・事後フックを使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// UpdateExerciseHistoryUsecaseImpl(
  ///   histories: histories,
  ///   health: health,
  ///   evaluateAutoUpdate: evaluateAutoUpdate,
  ///   evaluateAchievements: evaluateAchievements,
  ///   syncReminder: syncReminder,
  /// );
  /// ```
  const UpdateExerciseHistoryUsecaseImpl({
    required this.histories,
    required this.health,
    required this.evaluateAutoUpdate,
    required this.evaluateAchievements,
    required this.syncReminder,
  });

  /// 運動履歴の保存先。
  final ExerciseHistoryRepository histories;

  /// ヘルスへのサイクリング更新。
  final HealthWorkoutWriter health;

  /// 更新後の目標自動更新。
  final EvaluateDailyGoalAutoUpdateUsecase evaluateAutoUpdate;

  /// 更新後のアチーブメント評価。
  final EvaluateAchievementsUsecase evaluateAchievements;

  /// 更新後のリマインド同期。
  final SyncExerciseReminderUsecase syncReminder;

  /// [request] を検証し、更新後にヘルスと事後フックを走らせる。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   UpdateExerciseHistoryRequest(
  ///     id: '11111111-1111-4111-8111-111111111111',
  ///     creationStartedAt: DateTime.timestamp(),
  ///     capturedAt: DateTime.timestamp(),
  ///     recordedAt: DateTime.timestamp(),
  ///     distanceKm: 1,
  ///     duration: const Duration(minutes: 1),
  ///     caloriesKcal: 1,
  ///     previousHealthWorkoutId: null,
  ///   ),
  /// );
  /// ```
  @override
  Future<UpdateExerciseHistoryResult> execute(
    UpdateExerciseHistoryRequest request,
  ) async {
    final averageSpeedKmh = calculateAverageSpeedKmh(
      distanceKm: request.distanceKm,
      duration: request.duration,
    );
    if (!_isValid(request, averageSpeedKmh)) {
      return const UpdateExerciseHistoryResult(
        outcome: UpdateExerciseHistoryOutcome.invalidInput,
      );
    }

    try {
      final existing = await histories.findById(request.id);
      if (existing == null) {
        return const UpdateExerciseHistoryResult(
          outcome: UpdateExerciseHistoryOutcome.saveFailed,
        );
      }

      final updated = await histories.update(
        id: request.id,
        creationStartedAt: existing.creationStartedAt,
        capturedAt: request.photoBytes == null
            ? existing.capturedAt
            : request.capturedAt,
        recordedAt: request.recordedAt,
        recordedAtManuallySet: true,
        distanceKm: request.distanceKm,
        duration: request.duration,
        caloriesKcal: request.caloriesKcal,
        averageSpeedKmh: averageSpeedKmh!,
        photoBytes: request.photoBytes,
      );

      final healthId = existing.healthWorkoutId;
      if (healthId != null) {
        await _updateHealth(request: request, externalId: healthId);
      }

      final now = DateTime.now();
      var goalAutoUpdated = false;
      try {
        final autoUpdate = await evaluateAutoUpdate.execute(
          EvaluateDailyGoalAutoUpdateRequest(now: now),
        );
        goalAutoUpdated = autoUpdate.applied;
      } on Object {
        // 目標自動更新の失敗で、更新済みの履歴を saveFailed にしない。
      }
      try {
        await syncReminder.execute(SyncExerciseReminderRequest(now: now));
      } on Object {
        // 通知の同期失敗で、更新済みの履歴を saveFailed にしない。
      }

      var newlyUnlocked = const <AchievementUnlock>[];
      try {
        final evaluated = await evaluateAchievements.execute(
          EvaluateAchievementsRequest(now: now, emitNotifications: true),
        );
        newlyUnlocked = evaluated.newlyUnlocked;
      } on Object {
        // アチーブメント評価失敗でも更新 success を維持するため newly を空にする。
        newlyUnlocked = const [];
      }

      return UpdateExerciseHistoryResult(
        outcome: UpdateExerciseHistoryOutcome.success,
        history: updated,
        recordedLocalDayChanged: !_sameLocalDay(
          existing.recordedAt,
          request.recordedAt,
        ),
        goalAutoUpdated: goalAutoUpdated,
        newlyUnlockedAchievements: newlyUnlocked,
      );
    } on Object {
      return const UpdateExerciseHistoryResult(
        outcome: UpdateExerciseHistoryOutcome.saveFailed,
      );
    }
  }

  /// 作成時と同じ登録可能条件と、再計算した平均速度を満たすか。
  ///
  /// Example:
  /// ```dart
  /// _isValid(request, 24);
  /// ```
  static bool _isValid(
    UpdateExerciseHistoryRequest request,
    double? averageSpeedKmh,
  ) {
    if (request.duration <= Duration.zero) {
      return false;
    }
    if (averageSpeedKmh == null ||
        !averageSpeedKmh.isFinite ||
        averageSpeedKmh < 0) {
      return false;
    }
    if (request.distanceKm < 0 || request.caloriesKcal < 0) {
      return false;
    }
    return true;
  }

  /// ヘルスを更新し、失敗や例外は握りつぶす。
  ///
  /// Example:
  /// ```dart
  /// await _updateHealth(request: request, externalId: 'health-1');
  /// ```
  Future<void> _updateHealth({
    required UpdateExerciseHistoryRequest request,
    required String externalId,
  }) async {
    try {
      final start = request.recordedAt;
      final end = request.recordedAt.add(request.duration);
      await health.updateCycling(
        externalId: externalId,
        start: start,
        end: end,
        distanceKm: request.distanceKm,
        duration: request.duration,
        caloriesKcal: request.caloriesKcal,
      );
    } on Object {
      // ヘルス失敗でも CogLog 側の更新 success を維持する。
    }
  }

  /// 現地暦日が同じか。
  ///
  /// Example:
  /// ```dart
  /// _sameLocalDay(DateTime.timestamp(), DateTime.timestamp());
  /// ```
  static bool _sameLocalDay(DateTime a, DateTime b) {
    final localA = a.toLocal();
    final localB = b.toLocal();
    return localA.year == localB.year &&
        localA.month == localB.month &&
        localA.day == localB.day;
  }
}
