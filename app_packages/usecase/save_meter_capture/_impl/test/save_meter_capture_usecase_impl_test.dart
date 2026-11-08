import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:infra_health_workout_testing/infra_health_workout_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';
import 'package:usecase_save_meter_capture_impl/usecase_save_meter_capture_impl.dart';

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

  // S1: 正常 + health false → outcome success。
  test('S1: create 成功かつ health false でも success', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: false);

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
    ).execute(validRequest());

    expect(result.outcome, SaveMeterCaptureOutcome.success);
    expect(result.healthWriteSucceeded, isFalse);
    expect(result.history, isNotNull);
    expect(result.history!.distanceKm, 12);
    expect(health.writeCallCount, 1);
    expect(health.lastDistanceKm, 12);
    expect(health.lastDuration, const Duration(minutes: 30));
    expect(health.lastCaloriesKcal, 200);
    expect(health.lastStart, recordedAt);
    expect(health.lastEnd, recordedAt.add(const Duration(minutes: 30)));

    final listed = await histories.list();
    expect(listed, hasLength(1));
  });

  // S2: duration 0 → invalidInput、create 未呼出。
  test('S2: 運動時間 0 は invalidInput で create しない', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: true);
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
    ).execute(request);

    expect(result.outcome, SaveMeterCaptureOutcome.invalidInput);
    expect(result.history, isNull);
    expect(health.writeCallCount, 0);
    expect(await histories.list(), isEmpty);
  });

  test('負の距離は invalidInput', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter();
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
    ).execute(request);

    expect(result.outcome, SaveMeterCaptureOutcome.invalidInput);
    expect(await histories.list(), isEmpty);
    expect(health.writeCallCount, 0);
  });

  test('health 成功時は healthWriteSucceeded true', () async {
    final histories = MemoryExerciseHistoryRepository();
    final health = FakeHealthWorkoutWriter(succeed: true);

    final result = await SaveMeterCaptureUsecaseImpl(
      histories: histories,
      health: health,
    ).execute(validRequest());

    expect(result.outcome, SaveMeterCaptureOutcome.success);
    expect(result.healthWriteSucceeded, isTrue);
  });
}
