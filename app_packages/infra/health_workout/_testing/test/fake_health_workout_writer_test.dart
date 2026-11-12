import 'package:infra_health_workout_testing/infra_health_workout_testing.dart';
import 'package:test/test.dart';

void main() {
  test('成功時は fake-health-n と引数記録', () async {
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
      'fake-health-1',
    );
    expect(writer.writeCallCount, 1);
    expect(writer.lastStart, start);
    expect(writer.lastEnd, end);
    expect(writer.lastDistanceKm, 12);
    expect(writer.lastDuration, const Duration(hours: 1));
    expect(writer.lastCaloriesKcal, 300);
  });

  test('succeed false で write は null', () async {
    final writer = FakeHealthWorkoutWriter(succeed: false);
    expect(
      await writer.writeCycling(
        start: DateTime.utc(2026, 11, 8),
        end: DateTime.utc(2026, 11, 8, 1),
        distanceKm: 1,
        duration: const Duration(minutes: 1),
        caloriesKcal: 1,
      ),
      isNull,
    );
  });

  test('updateCycling は externalId を記録し succeed を返す', () async {
    final writer = FakeHealthWorkoutWriter();
    expect(
      await writer.updateCycling(
        externalId: 'fake-health-1',
        start: DateTime.utc(2026, 11, 8),
        end: DateTime.utc(2026, 11, 8, 1),
        distanceKm: 2,
        duration: const Duration(minutes: 2),
        caloriesKcal: 20,
      ),
      isTrue,
    );
    expect(writer.updateCallCount, 1);
    expect(writer.lastExternalId, 'fake-health-1');
    expect(writer.lastDistanceKm, 2);
  });

  test('deleteCycling は externalId を記録し succeed を返す', () async {
    final writer = FakeHealthWorkoutWriter();
    expect(await writer.deleteCycling(externalId: 'fake-health-9'), isTrue);
    expect(writer.deleteCallCount, 1);
    expect(writer.lastExternalId, 'fake-health-9');
  });

  test('succeed false で update/delete は false', () async {
    final writer = FakeHealthWorkoutWriter(succeed: false);
    expect(
      await writer.updateCycling(
        externalId: 'x',
        start: DateTime.utc(2026, 11, 8),
        end: DateTime.utc(2026, 11, 8, 1),
        distanceKm: 1,
        duration: const Duration(minutes: 1),
        caloriesKcal: 1,
      ),
      isFalse,
    );
    expect(await writer.deleteCycling(externalId: 'x'), isFalse);
  });
}
