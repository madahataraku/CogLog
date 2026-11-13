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
    healthWorkoutId: null,
  );
}

void main() {
  final now = DateTime(2026, 11, 5, 15);

  test('直前運動日が無ければ null', () {
    expect(DaysSincePreviousExerciseDay.of(const [], now), isNull);
  });

  test('本日の履歴だけなら null', () {
    expect(
      DaysSincePreviousExerciseDay.of([
        ride(recordedAt: DateTime(2026, 11, 5, 10)),
        ride(
          recordedAt: DateTime(2026, 11, 5, 18),
          id: '22222222-2222-4222-8222-222222222222',
        ),
      ], now),
      isNull,
    );
  });

  test('直前運動日との差が 6 日', () {
    expect(
      DaysSincePreviousExerciseDay.of([
        ride(recordedAt: DateTime(2026, 10, 30, 12)),
        ride(
          recordedAt: DateTime(2026, 11, 5, 10),
          id: '22222222-2222-4222-8222-222222222222',
        ),
      ], now),
      6,
    );
  });

  test('直前運動日との差が 7 日', () {
    expect(
      DaysSincePreviousExerciseDay.of([
        ride(recordedAt: DateTime(2026, 10, 29, 12)),
      ], now),
      7,
    );
  });
}
