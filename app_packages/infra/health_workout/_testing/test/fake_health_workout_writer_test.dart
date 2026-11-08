import 'package:infra_health_workout_testing/infra_health_workout_testing.dart';
import 'package:test/test.dart';

void main() {
  test('成功時 true と引数記録', () async {
    final writer = FakeHealthWorkoutWriter();
    final start = DateTime.utc(2026, 11, 8);
    final end = DateTime.utc(2026, 11, 8, 1);

    expect(
      await writer.writeCycling(
        start: start,
        end: end,
        distanceKm: 12,
        duration: const Duration(hours: 1),
        caloriesKcal: 300,
      ),
      isTrue,
    );
    expect(writer.writeCallCount, 1);
    expect(writer.lastStart, start);
    expect(writer.lastEnd, end);
    expect(writer.lastDistanceKm, 12);
    expect(writer.lastDuration, const Duration(hours: 1));
    expect(writer.lastCaloriesKcal, 300);
  });

  test('succeed false で false', () async {
    final writer = FakeHealthWorkoutWriter(succeed: false);
    expect(
      await writer.writeCycling(
        start: DateTime.utc(2026, 11, 8),
        end: DateTime.utc(2026, 11, 8, 1),
        distanceKm: 1,
        duration: const Duration(minutes: 1),
        caloriesKcal: 1,
      ),
      isFalse,
    );
  });
}
