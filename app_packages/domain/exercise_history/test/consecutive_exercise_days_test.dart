import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

ExerciseHistory ride({
  required DateTime recordedAt,
  String id = '11111111-1111-4111-8111-111111111111',
}) {
  return ExerciseHistory(
    id: id,
    savedAt: recordedAt,
    creationStartedAt: recordedAt,
    capturedAt: recordedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: 1,
    duration: const Duration(minutes: 1),
    caloriesKcal: 1,
    averageSpeedKmh: 1,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
  );
}

void main() {
  final now = DateTime(2026, 11, 5, 15);

  test('本日に履歴が無ければ 0', () {
    expect(
      ConsecutiveExerciseDays.of([
        ride(recordedAt: DateTime(2026, 11, 4, 12)),
      ], now),
      0,
    );
  });

  test('本日だけのとき 1', () {
    expect(
      ConsecutiveExerciseDays.of([
        ride(recordedAt: DateTime(2026, 11, 5, 10)),
        ride(
          recordedAt: DateTime(2026, 11, 5, 18),
          id: '22222222-2222-4222-8222-222222222222',
        ),
      ], now),
      1,
    );
  });

  test('本日と昨日があれば 2、途切れた先は数えない', () {
    expect(
      ConsecutiveExerciseDays.of([
        ride(recordedAt: DateTime(2026, 11, 5, 12)),
        ride(
          recordedAt: DateTime(2026, 11, 4, 12),
          id: '22222222-2222-4222-8222-222222222222',
        ),
        ride(
          recordedAt: DateTime(2026, 11, 2, 12),
          id: '33333333-3333-4333-8333-333333333333',
        ),
      ], now),
      2,
    );
  });
}
