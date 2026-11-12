import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';
import 'package:usecase_load_exercise_history_month_impl/usecase_load_exercise_history_month_impl.dart';

void main() {
  test('月内の全件を返し他月は含めない', () async {
    final repo = MemoryExerciseHistoryRepository();
    await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 1),
      capturedAt: DateTime.utc(2026, 11, 1),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      healthWorkoutId: null,
      photoBytes: Uint8List.fromList([1]),
    );
    await repo.create(
      creationStartedAt: DateTime.utc(2026, 10, 1),
      capturedAt: DateTime.utc(2026, 10, 1),
      recordedAt: DateTime.utc(2026, 10, 5),
      recordedAtManuallySet: false,
      distanceKm: 2,
      duration: const Duration(minutes: 2),
      caloriesKcal: 2,
      averageSpeedKmh: 2,
      healthWorkoutId: null,
      photoBytes: Uint8List.fromList([2]),
    );
    final usecase = LoadExerciseHistoryMonthUsecaseImpl(histories: repo);
    final result = await usecase.execute(
      const LoadExerciseHistoryMonthRequest(year: 2026, month: 11),
    );
    expect(result.items, hasLength(1));
    expect(result.items.single.distanceKm, 1);
  });
}
