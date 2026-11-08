import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';
import 'package:usecase_load_exercise_history_page_impl/usecase_load_exercise_history_page_impl.dart';

void main() {
  test('件数が limit 未満なら hasMore は false', () async {
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
      photoBytes: Uint8List.fromList([1]),
    );
    final usecase = LoadExerciseHistoryPageUsecaseImpl(histories: repo);
    final result = await usecase.execute(
      const LoadExerciseHistoryPageRequest(year: 2026, month: 11, offset: 0),
    );
    expect(result.items, hasLength(1));
    expect(result.hasMore, isFalse);
  });

  test('件数が limit と同じなら hasMore は true', () async {
    final repo = MemoryExerciseHistoryRepository();
    for (var i = 0; i < 2; i++) {
      await repo.create(
        creationStartedAt: DateTime.utc(2026, 11, 1 + i),
        capturedAt: DateTime.utc(2026, 11, 1 + i),
        recordedAt: DateTime.utc(2026, 11, 5),
        recordedAtManuallySet: false,
        distanceKm: 1,
        duration: const Duration(minutes: 1),
        caloriesKcal: 1,
        averageSpeedKmh: 1,
        photoBytes: Uint8List.fromList([i]),
      );
    }
    final usecase = LoadExerciseHistoryPageUsecaseImpl(histories: repo);
    final result = await usecase.execute(
      const LoadExerciseHistoryPageRequest(
        year: 2026,
        month: 11,
        offset: 0,
        limit: 2,
      ),
    );
    expect(result.items, hasLength(2));
    expect(result.hasMore, isTrue);
  });
}
