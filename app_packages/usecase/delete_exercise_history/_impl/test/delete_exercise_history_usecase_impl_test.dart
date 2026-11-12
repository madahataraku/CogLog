import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:infra_health_workout_testing/infra_health_workout_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_delete_exercise_history/usecase_delete_exercise_history.dart';
import 'package:usecase_delete_exercise_history_impl/usecase_delete_exercise_history_impl.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

final class _FakeEvaluate implements EvaluateDailyGoalAutoUpdateUsecase {
  _FakeEvaluate({this.applied = false});

  final bool applied;
  int callCount = 0;

  @override
  Future<EvaluateDailyGoalAutoUpdateResult> execute(
    EvaluateDailyGoalAutoUpdateRequest request,
  ) async {
    callCount += 1;
    return EvaluateDailyGoalAutoUpdateResult(applied: applied);
  }
}

final class _FakeEvaluateAchievements implements EvaluateAchievementsUsecase {
  int callCount = 0;

  @override
  Future<EvaluateAchievementsResult> execute(
    EvaluateAchievementsRequest request,
  ) async {
    callCount += 1;
    return const EvaluateAchievementsResult(newlyUnlocked: []);
  }
}

final class _FakeSync implements SyncExerciseReminderUsecase {
  int callCount = 0;

  @override
  Future<SyncExerciseReminderResult> execute(
    SyncExerciseReminderRequest request,
  ) async {
    callCount += 1;
    return const SyncExerciseReminderResult(scheduled: false);
  }
}

final class _ThrowingDeleteHealth implements HealthWorkoutWriter {
  int deleteCallCount = 0;

  @override
  Future<String?> writeCycling({
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  }) async => null;

  @override
  Future<bool> updateCycling({
    required String externalId,
    required DateTime start,
    required DateTime end,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
  }) async => false;

  @override
  Future<bool> deleteCycling({required String externalId}) async {
    deleteCallCount += 1;
    throw StateError('health delete failed');
  }
}

void main() {
  final photo = Uint8List.fromList([1, 2, 3]);

  Future<String> seed(
    MemoryExerciseHistoryRepository histories, {
    String? healthWorkoutId,
  }) async {
    final created = await histories.create(
      creationStartedAt: DateTime.utc(2026, 11, 8, 10),
      capturedAt: DateTime.utc(2026, 11, 8, 10, 1),
      recordedAt: DateTime.utc(2026, 11, 8, 10, 1),
      recordedAtManuallySet: false,
      distanceKm: 10,
      duration: const Duration(minutes: 20),
      caloriesKcal: 150,
      averageSpeedKmh: 30,
      healthWorkoutId: healthWorkoutId,
      photoBytes: photo,
    );
    return created.id;
  }

  test('healthId ありなら delete 後に deleteCycling と hooks', () async {
    final histories = MemoryExerciseHistoryRepository();
    final id = await seed(histories, healthWorkoutId: 'health-1');
    final health = FakeHealthWorkoutWriter(succeed: true);
    final evaluate = _FakeEvaluate(applied: true);
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result =
        await DeleteExerciseHistoryUsecaseImpl(
          histories: histories,
          health: health,
          evaluateAutoUpdate: evaluate,
          evaluateAchievements: achievements,
          syncReminder: sync,
        ).execute(
          DeleteExerciseHistoryRequest(id: id, healthWorkoutId: 'health-1'),
        );

    expect(result.outcome, DeleteExerciseHistoryOutcome.success);
    expect(result.goalAutoUpdated, isTrue);
    expect(await histories.list(), isEmpty);
    expect(health.deleteCallCount, 1);
    expect(health.lastExternalId, 'health-1');
    expect(evaluate.callCount, 1);
    expect(achievements.callCount, 1);
    expect(sync.callCount, 1);
  });

  test('healthId null ならヘルス呼ばず hooks のみ', () async {
    final histories = MemoryExerciseHistoryRepository();
    final id = await seed(histories);
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await DeleteExerciseHistoryUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(DeleteExerciseHistoryRequest(id: id, healthWorkoutId: null));

    expect(result.outcome, DeleteExerciseHistoryOutcome.success);
    expect(await histories.list(), isEmpty);
    expect(health.deleteCallCount, 0);
    expect(health.updateCallCount, 0);
    expect(health.writeCallCount, 0);
    expect(evaluate.callCount, 1);
    expect(achievements.callCount, 1);
    expect(sync.callCount, 1);
  });

  test('ヘルス削除失敗・例外でも CogLog 削除は success', () async {
    final histories = MemoryExerciseHistoryRepository();
    final id = await seed(histories, healthWorkoutId: 'health-1');
    final health = _ThrowingDeleteHealth();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result =
        await DeleteExerciseHistoryUsecaseImpl(
          histories: histories,
          health: health,
          evaluateAutoUpdate: evaluate,
          evaluateAchievements: achievements,
          syncReminder: sync,
        ).execute(
          DeleteExerciseHistoryRequest(id: id, healthWorkoutId: 'health-1'),
        );

    expect(result.outcome, DeleteExerciseHistoryOutcome.success);
    expect(await histories.list(), isEmpty);
    expect(health.deleteCallCount, 1);
    expect(evaluate.callCount, 1);
  });

  test('未知 id は notFoundOrFailed で hooks なし', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result =
        await DeleteExerciseHistoryUsecaseImpl(
          histories: histories,
          health: health,
          evaluateAutoUpdate: evaluate,
          evaluateAchievements: achievements,
          syncReminder: sync,
        ).execute(
          const DeleteExerciseHistoryRequest(
            id: 'missing-id',
            healthWorkoutId: 'health-1',
          ),
        );

    expect(result.outcome, DeleteExerciseHistoryOutcome.notFoundOrFailed);
    expect(health.deleteCallCount, 0);
    expect(evaluate.callCount, 0);
    expect(achievements.callCount, 0);
    expect(sync.callCount, 0);
  });
}
