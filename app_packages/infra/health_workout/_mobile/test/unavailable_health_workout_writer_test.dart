import 'package:infra_health_workout_mobile/infra_health_workout_mobile.dart';
import 'package:test/test.dart';

void main() {
  test('writeCycling は常に null', () async {
    final id = await const UnavailableHealthWorkoutWriter().writeCycling(
      start: DateTime.utc(2026, 11, 8),
      end: DateTime.utc(2026, 11, 8, 1),
      distanceKm: 10,
      duration: const Duration(hours: 1),
      caloriesKcal: 200,
    );
    expect(id, isNull);
  });

  test('updateCycling / deleteCycling は常に false', () async {
    const writer = UnavailableHealthWorkoutWriter();
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
