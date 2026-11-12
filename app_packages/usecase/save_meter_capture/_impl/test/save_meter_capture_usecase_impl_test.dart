import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:infra_health_workout_testing/infra_health_workout_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';
import 'package:usecase_save_meter_capture_impl/usecase_save_meter_capture_impl.dart';
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
  _FakeEvaluateAchievements({
    this.newlyUnlocked = const [],
    this.throwOnExecute = false,
  });

  final List<AchievementUnlock> newlyUnlocked;
  final bool throwOnExecute;
  int callCount = 0;

  @override
  Future<EvaluateAchievementsResult> execute(
    EvaluateAchievementsRequest request,
  ) async {
    callCount += 1;
    if (throwOnExecute) {
      throw StateError('evaluate failed');
    }
    return EvaluateAchievementsResult(newlyUnlocked: newlyUnlocked);
  }
}

final class _FakeSync implements SyncExerciseReminderUsecase {
  _FakeSync({this.throwOnExecute = false});

  final bool throwOnExecute;
  int callCount = 0;

  @override
  Future<SyncExerciseReminderResult> execute(
    SyncExerciseReminderRequest request,
  ) async {
    callCount += 1;
    if (throwOnExecute) {
      throw StateError('sync failed');
    }
    return const SyncExerciseReminderResult(scheduled: false);
  }
}

void main() {
  final creationStartedAt = DateTime.utc(2026, 11, 8, 10);
  final capturedAt = DateTime.utc(2026, 11, 8, 10, 1);
  final recordedAt = DateTime.utc(2026, 11, 8, 10, 1);
  final photo = Uint8List.fromList([1, 2, 3]);

  SaveMeterCaptureRequest validRequest() => SaveMeterCaptureRequest(
    creationStartedAt: creationStartedAt,
    capturedAt: capturedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: 12,
    duration: const Duration(minutes: 30),
    caloriesKcal: 200,
    averageSpeedKmh: 24,
    photoBytes: photo,
  );

  test('S1: create 成功かつ health false でも success', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: false);
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(validRequest());

    expect(result.outcome, SaveMeterCaptureOutcome.success);
    expect(result.healthWriteSucceeded, isFalse);
    expect(result.goalAutoUpdated, isFalse);
    expect(result.newlyUnlockedAchievements, isEmpty);
    expect(result.history, isNotNull);
    expect(result.history!.distanceKm, 12);
    expect(result.history!.healthWorkoutId, isNull);
    expect(health.writeCallCount, 1);
    expect(evaluate.callCount, 1);
    expect(achievements.callCount, 1);
    expect(sync.callCount, 1);

    final listed = await histories.list();
    expect(listed, hasLength(1));
  });

  test('S2: 運動時間 0 は invalidInput で create しない', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: true);
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();
    final request = SaveMeterCaptureRequest(
      creationStartedAt: creationStartedAt,
      capturedAt: capturedAt,
      recordedAt: recordedAt,
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: Duration.zero,
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: photo,
    );

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(request);

    expect(result.outcome, SaveMeterCaptureOutcome.invalidInput);
    expect(result.history, isNull);
    expect(health.writeCallCount, 0);
    expect(evaluate.callCount, 0);
    expect(achievements.callCount, 0);
    expect(sync.callCount, 0);
    expect(await histories.list(), isEmpty);
  });

  test('負の距離は invalidInput', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync();
    final request = SaveMeterCaptureRequest(
      creationStartedAt: creationStartedAt,
      capturedAt: capturedAt,
      recordedAt: recordedAt,
      recordedAtManuallySet: false,
      distanceKm: -1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: photo,
    );

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(request);

    expect(result.outcome, SaveMeterCaptureOutcome.invalidInput);
    expect(await histories.list(), isEmpty);
    expect(health.writeCallCount, 0);
    expect(evaluate.callCount, 0);
    expect(achievements.callCount, 0);
    expect(sync.callCount, 0);
  });

  test(
    'health 成功時は healthWriteSucceeded true かつ healthWorkoutId を保存',
    () async {
      final histories = MemoryExerciseHistoryRepository();
      final health = FakeHealthWorkoutWriter(succeed: true);
      final evaluate = _FakeEvaluate(applied: true);
      final achievements = _FakeEvaluateAchievements(
        newlyUnlocked: [
          AchievementUnlock(
            id: 'first_record',
            unlockedAt: DateTime.utc(2026, 11, 8),
          ),
        ],
      );
      final sync = _FakeSync();

      final result = await SaveMeterCaptureUsecaseImpl(
        histories: histories,
        health: health,
        evaluateAutoUpdate: evaluate,
        evaluateAchievements: achievements,
        syncReminder: sync,
      ).execute(validRequest());

      expect(result.outcome, SaveMeterCaptureOutcome.success);
      expect(result.healthWriteSucceeded, isTrue);
      expect(result.history!.healthWorkoutId, 'fake-health-1');
      expect(result.goalAutoUpdated, isTrue);
      expect(result.newlyUnlockedAchievements, hasLength(1));
      expect(result.newlyUnlockedAchievements.single.id, 'first_record');
      expect(sync.callCount, 1);

      final listed = await histories.list();
      expect(listed.single.healthWorkoutId, 'fake-health-1');
    },
  );

  test('同期例外でも保存済みなら success', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: true);
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements();
    final sync = _FakeSync(throwOnExecute: true);

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(validRequest());

    expect(result.outcome, SaveMeterCaptureOutcome.success);
    expect(result.history, isNotNull);
    expect(sync.callCount, 1);
    expect(achievements.callCount, 1);
    expect(await histories.list(), hasLength(1));
  });

  test('evaluate throw でも create success で newly 空', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: true);
    final evaluate = _FakeEvaluate();
    final achievements = _FakeEvaluateAchievements(throwOnExecute: true);
    final sync = _FakeSync();

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
      evaluateAchievements: achievements,
      syncReminder: sync,
    ).execute(validRequest());

    expect(result.outcome, SaveMeterCaptureOutcome.success);
    expect(result.newlyUnlockedAchievements, isEmpty);
    expect(achievements.callCount, 1);
    expect(await histories.list(), hasLength(1));
  });
}
