import 'package:infra_health_workout_mobile/infra_health_workout_mobile.dart';
import 'package:test/test.dart';

void main() {
  test('writeCycling は常に false', () async {
    final ok = await const UnavailableHealthWorkoutWriter().writeCycling(
      start: DateTime.utc(2026, 11, 8),
      end: DateTime.utc(2026, 11, 8, 1),
      distanceKm: 10,
      duration: const Duration(hours: 1),
      caloriesKcal: 200,
    );
    expect(ok, isFalse);
  });
}
