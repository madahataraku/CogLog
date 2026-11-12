import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_health_workout/infra_health_workout.dart';
import 'package:infra_health_workout_testing/infra_health_workout_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';
import 'package:usecase_update_exercise_history/usecase_update_exercise_history.dart';
import 'package:usecase_update_exercise_history_impl/usecase_update_exercise_history_impl.dart';

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

final class _ThrowingHealth implements HealthWorkoutWriter {
  int updateCallCount = 0;

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
  }) async {
    updateCallCount += 1;
    throw StateError('health update failed');
  }

  @override
  Future<bool> deleteCycling({required String externalId}) async => false;
}

void main() {
  final creationStartedAt = DateTime.utc(2026, 11, 8, 10);
  final capturedAt = DateTime.utc(2026, 11, 8, 10, 1);
  final recordedAt = DateTime.utc(2026, 11, 8, 10, 1);
  final photo = Uint8List.fromList([1, 2, 3]);

  Future<ExerciseHistory> seed(
    MemoryExerciseHistoryRepository histories, {
    String? healthWorkoutId,
    DateTime? recorded,
    double distanceKm = 10,
    Duration duration = const Duration(minutes: 20),
    double averageSpeedKmh = 30,
  }) {
    return histories.create(
      creationStartedAt: creationStartedAt,
      capturedAt: capturedAt,
      recordedAt: recorded ?? recordedAt,
      recordedAtManuallySet: false,
      distanceKm: distanceKm,
      duration: duration,
      caloriesKcal: 150,
      averageSpeedKmh: averageSpeedKmh,
      healthWorkoutId: healthWorkoutId,
      photoBytes: photo,
    );
  }

  UpdateExerciseHistoryRequest requestFor(
    ExerciseHistory existing, {
    DateTime? recorded,
    double distanceKm = 12,
    Duration duration = const Duration(minutes: 30),
    double caloriesKcal = 200,
    Uint8List? photoBytes,
    DateTime? captured,
  }) {
    return UpdateExerciseHistoryRequest(
      id: existing.id,
      creationStartedAt: existing.creationStartedAt,
      capturedAt: captured ?? existing.capturedAt,
      recordedAt: recorded ?? existing.recordedAt,
      distanceKm: distanceKm,
      duration: duration,
      caloriesKcal: caloriesKcal,
      previousHealthWorkoutId: existing.healthWorkoutId,
      photoBytes: photoBytes,
    );
  }

  test('距離・時間変更で平均速度再計算・savedAt不変・手変更真・hooks 1回', () async {
    final histories = MemoryExerciseHistoryRepository();
    final existing = await seed(histories);
    final savedAt = existing.savedAt;
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate(applied: true);
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await UpdateExerciseHistoryUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(requestFor(existing));

    expect(result.outcome, UpdateExerciseHistoryOutcome.success);
    expect(result.history, isNotNull);
    expect(result.history!.averageSpeedKmh, 24);
    expect(result.history!.distanceKm, 12);
    expect(result.history!.duration, const Duration(minutes: 30));
    expect(result.history!.savedAt, savedAt);
    expect(result.history!.recordedAtManuallySet, isTrue);
    expect(result.recordedLocalDayChanged, isFalse);
    expect(result.goalAutoUpdated, isTrue);
    expect(health.updateCallCount, 0);
    expect(evaluate.callCount, 1);
    expect(achievements.callCount, 1);
    expect(sync.callCount, 1);
  });

  test('運動時間 0 は invalidInput で update しない', () async {
    final histories = MemoryExerciseHistoryRepository();
    final existing = await seed(histories);
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await UpdateExerciseHistoryUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(requestFor(existing, duration: Duration.zero, distanceKm: 1));

    expect(result.outcome, UpdateExerciseHistoryOutcome.invalidInput);
    expect(result.history, isNull);
    expect(health.updateCallCount, 0);
    expect(evaluate.callCount, 0);
    expect(achievements.callCount, 0);
    expect(sync.callCount, 0);

    final listed = await histories.list();
    expect(listed.single.distanceKm, 10);
    expect(listed.single.recordedAtManuallySet, isFalse);
  });

  test('healthId ありなら updateCycling。失敗しても success', () async {
    final histories = MemoryExerciseHistoryRepository();
    final existing = await seed(histories, healthWorkoutId: 'health-1');
    final health = FakeHealthWorkoutWriter(succeed: false);
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await UpdateExerciseHistoryUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(requestFor(existing));

    expect(result.outcome, UpdateExerciseHistoryOutcome.success);
    expect(health.updateCallCount, 1);
    expect(health.lastExternalId, 'health-1');
    expect(result.history!.healthWorkoutId, 'health-1');
  });

  test('health update 例外でも success', () async {
    final histories = MemoryExerciseHistoryRepository();
    final existing = await seed(histories, healthWorkoutId: 'health-1');
    final health = _ThrowingHealth();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await UpdateExerciseHistoryUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(requestFor(existing));

    expect(result.outcome, UpdateExerciseHistoryOutcome.success);
    expect(health.updateCallCount, 1);
  });

  test('healthId null ならヘルス呼ばれない', () async {
    final histories = MemoryExerciseHistoryRepository();
    final existing = await seed(histories, healthWorkoutId: null);
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await UpdateExerciseHistoryUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(requestFor(existing));

    expect(result.outcome, UpdateExerciseHistoryOutcome.success);
    expect(health.updateCallCount, 0);
    expect(health.writeCallCount, 0);
    expect(health.deleteCallCount, 0);
  });

  test('photoBytes ありなら更新し capturedAt を新値に', () async {
    final histories = MemoryExerciseHistoryRepository();
    final existing = await seed(histories);
    final newCaptured = DateTime.utc(2026, 11, 9, 12);
    final newPhoto = Uint8List.fromList([9, 8, 7]);
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result =
        await UpdateExerciseHistoryUsecaseImpl(
          histories: histories,
          health: health,
          evaluateAutoUpdate: evaluate,
          evaluateAchievements: achievements,
          syncReminder: sync,
        ).execute(
          requestFor(existing, photoBytes: newPhoto, captured: newCaptured),
        );

    expect(result.outcome, UpdateExerciseHistoryOutcome.success);
    expect(result.history!.capturedAt, newCaptured.toUtc());
    expect(result.history!.recordedAtManuallySet, isTrue);

    final path = await histories.photoAbsolutePath(existing.id);
    expect(path, isNotNull);
  });

  test('暦日変更なら recordedLocalDayChanged true', () async {
    final histories = MemoryExerciseHistoryRepository();
    final existing = await seed(histories, recorded: DateTime(2026, 11, 8, 15));
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await UpdateExerciseHistoryUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(requestFor(existing, recorded: DateTime(2026, 11, 9, 15)));

    expect(result.outcome, UpdateExerciseHistoryOutcome.success);
    expect(result.recordedLocalDayChanged, isTrue);
  });

  test('負の距離は invalidInput', () async {
    final histories = MemoryExerciseHistoryRepository();
    final existing = await seed(histories);
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await UpdateExerciseHistoryUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(requestFor(existing, distanceKm: -1));

    expect(result.outcome, UpdateExerciseHistoryOutcome.invalidInput);
    expect(health.updateCallCount, 0);
    expect(evaluate.callCount, 0);
  });

  test('未知 id は saveFailed', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result =
        await UpdateExerciseHistoryUsecaseImpl(
          histories: histories,
          health: health,
          evaluateAutoUpdate: evaluate,
          evaluateAchievements: achievements,
          syncReminder: sync,
        ).execute(
          UpdateExerciseHistoryRequest(
            id: 'missing-id',
            creationStartedAt: creationStartedAt,
            capturedAt: capturedAt,
            recordedAt: recordedAt,
            distanceKm: 1,
            duration: const Duration(minutes: 1),
            caloriesKcal: 1,
            previousHealthWorkoutId: null,
          ),
        );

    expect(result.outcome, UpdateExerciseHistoryOutcome.saveFailed);
    expect(evaluate.callCount, 0);
  });
}
