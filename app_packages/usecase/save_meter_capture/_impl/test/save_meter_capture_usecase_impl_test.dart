import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:infra_health_workout_testing/infra_health_workout_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';
import 'package:usecase_save_meter_capture_impl/usecase_save_meter_capture_impl.dart';

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

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
    ).execute(validRequest());

    expect(result.outcome, SaveMeterCaptureOutcome.success);
    expect(result.healthWriteSucceeded, isFalse);
    expect(result.goalAutoUpdated, isFalse);
    expect(result.history, isNotNull);
    expect(result.history!.distanceKm, 12);
    expect(health.writeCallCount, 1);
    expect(evaluate.callCount, 1);

    final listed = await histories.list();
    expect(listed, hasLength(1));
  });

  test('S2: 運動時間 0 は invalidInput で create しない', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: true);
    final evaluate = _FakeEvaluate();
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
    ).execute(request);

    expect(result.outcome, SaveMeterCaptureOutcome.invalidInput);
    expect(result.history, isNull);
    expect(health.writeCallCount, 0);
    expect(evaluate.callCount, 0);
    expect(await histories.list(), isEmpty);
  });

  test('負の距離は invalidInput', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter();
    final evaluate = _FakeEvaluate();
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
    ).execute(request);

    expect(result.outcome, SaveMeterCaptureOutcome.invalidInput);
    expect(await histories.list(), isEmpty);
    expect(health.writeCallCount, 0);
    expect(evaluate.callCount, 0);
  });

  test('health 成功時は healthWriteSucceeded true', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: true);
    final evaluate = _FakeEvaluate(applied: true);

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
      evaluateAutoUpdate: evaluate,
    ).execute(validRequest());

    expect(result.outcome, SaveMeterCaptureOutcome.success);
    expect(result.healthWriteSucceeded, isTrue);
    expect(result.goalAutoUpdated, isTrue);
  });
}
