import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day_impl/usecase_load_exercise_histories_for_same_recorded_day_impl.dart';

void main() {
  test('未知 ID は NotFound', () async {
    final usecase = LoadExerciseHistoriesForSameRecordedDayUsecaseImpl(
      histories: MemoryExerciseHistoryRepository(),
    );
    final result = await usecase.execute(
      const LoadExerciseHistoriesForSameRecordedDayRequest(id: 'missing'),
    );
    expect(result, isA<LoadExerciseHistoriesForSameRecordedDayNotFound>());
  });

  test('同一記録日の ID を作成開始日時降順で返し initialIndex を付ける', () async {
    final repo = MemoryExerciseHistoryRepository();
    final older = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5, 8),
      capturedAt: DateTime.utc(2026, 11, 5, 8),
      recordedAt: DateTime.utc(2026, 11, 5, 12),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1]),
    );
    final newer = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 5, 10),
      capturedAt: DateTime.utc(2026, 11, 5, 10),
      recordedAt: DateTime.utc(2026, 11, 5, 18),
      recordedAtManuallySet: false,
      distanceKm: 2,
      duration: const Duration(minutes: 2),
      caloriesKcal: 2,
      averageSpeedKmh: 2,
      photoBytes: Uint8List.fromList([2]),
    );
    await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 6, 8),
      capturedAt: DateTime.utc(2026, 11, 6, 8),
      recordedAt: DateTime.utc(2026, 11, 6, 12),
      recordedAtManuallySet: false,
      distanceKm: 3,
      duration: const Duration(minutes: 3),
      caloriesKcal: 3,
      averageSpeedKmh: 3,
      photoBytes: Uint8List.fromList([3]),
    );

    final usecase = LoadExerciseHistoriesForSameRecordedDayUsecaseImpl(
      histories: repo,
    );
    final result = await usecase.execute(
      LoadExerciseHistoriesForSameRecordedDayRequest(id: older.id),
    );
    expect(
      result,
      isA<LoadExerciseHistoriesForSameRecordedDaySuccess>()
          .having((r) => r.ids, 'ids', [newer.id, older.id])
          .having((r) => r.initialIndex, 'initialIndex', 1),
    );
  });
}
