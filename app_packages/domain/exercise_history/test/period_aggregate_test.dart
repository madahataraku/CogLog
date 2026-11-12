import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

ExerciseHistory ride({
  required DateTime recordedAt,
  double distanceKm = 1,
  double caloriesKcal = 1,
  Duration duration = const Duration(minutes: 1),
}) {
  const id = '11111111-1111-4111-8111-111111111111';
  return ExerciseHistory(
    id: id,
    savedAt: recordedAt,
    creationStartedAt: recordedAt,
    capturedAt: recordedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: distanceKm,
    duration: duration,
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: 1,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: null,
  );
}

void main() {
  final now = DateTime(2026, 11, 5, 15);

  test('期間の外は合計に入らない', () {
    final aggregate = PeriodAggregate.of([
      ride(recordedAt: DateTime(2026, 10, 31, 12), distanceKm: 9),
    ], PeriodWindow.month(now));
    expect(aggregate.hasHistory, isFalse);
  });

  test('同じ期間の 1.14 km を 2 件足すと 2.28', () {
    final aggregate = PeriodAggregate.of([
      ride(recordedAt: DateTime(2026, 11, 5, 10), distanceKm: 1.14),
      ride(recordedAt: DateTime(2026, 11, 5, 11), distanceKm: 1.14),
    ], PeriodWindow.today(now));
    expect(aggregate.count, 2);
    expect(aggregate.distanceKm, closeTo(2.28, 1e-9));
    expect(
      PeriodTotalText.of(
        aggregate: aggregate,
        metric: PeriodTotalMetric.distance,
      ),
      '2.3',
    );
  });

  test('本日に入る履歴は今週と今月にも 1 回ずつ入る', () {
    final histories = [
      ride(recordedAt: DateTime(2026, 11, 5, 12), distanceKm: 3),
    ];
    expect(PeriodAggregate.of(histories, PeriodWindow.today(now)).count, 1);
    expect(PeriodAggregate.of(histories, PeriodWindow.week(now)).count, 1);
    expect(PeriodAggregate.of(histories, PeriodWindow.month(now)).count, 1);
  });

  test('11月1日は今月に入り今週には入らない', () {
    final histories = [
      ride(recordedAt: DateTime(2026, 11, 1, 12)),
      ride(recordedAt: DateTime(2026, 11, 5, 12)),
    ];
    expect(PeriodAggregate.of(histories, PeriodWindow.week(now)).count, 1);
    expect(PeriodAggregate.of(histories, PeriodWindow.month(now)).count, 2);
  });
}
