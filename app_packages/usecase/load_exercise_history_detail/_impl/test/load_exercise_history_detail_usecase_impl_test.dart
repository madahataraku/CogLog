import 'dart:typed_data';

import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';
import 'package:usecase_load_exercise_history_detail_impl/usecase_load_exercise_history_detail_impl.dart';

void main() {
  test('未知 ID は notFound', () async {
    final usecase = LoadExerciseHistoryDetailUsecaseImpl(
      histories: MemoryExerciseHistoryRepository(),
    );
    final result = await usecase.execute(
      const LoadExerciseHistoryDetailRequest(
        id: '00000000-0000-4000-8000-000000000000',
      ),
    );
    expect(result, isA<LoadExerciseHistoryDetailNotFound>());
  });

  test('既存 ID は success と写真パス', () async {
    final repo = MemoryExerciseHistoryRepository();
    final created = await repo.create(
      creationStartedAt: DateTime.utc(2026, 11, 1),
      capturedAt: DateTime.utc(2026, 11, 1),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      photoBytes: Uint8List.fromList([1, 2, 3]),
    );
    final usecase = LoadExerciseHistoryDetailUsecaseImpl(histories: repo);
    final result = await usecase.execute(
      LoadExerciseHistoryDetailRequest(id: created.id),
    );
    expect(result, isA<LoadExerciseHistoryDetailSuccess>());
    final success = result as LoadExerciseHistoryDetailSuccess;
    expect(success.history.id, created.id);
    expect(success.photoAbsolutePath, isNotNull);
  });
}
