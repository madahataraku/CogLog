import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

ExerciseHistory ride({
  required DateTime recordedAt,
  required double caloriesKcal,
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
    duration: const Duration(minutes: 30),
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: 1,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: null,
  );
}

void main() {
  const goal = DailyGoal(caloriesKcal: 100);
  final now = DateTime(2026, 11, 5, 15);

  test('本日未達なら 0', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 50)],
        goal,
        now,
        null,
      ),
      0,
    );
  });

  test('本日達・昨日未達なら 1', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [
          ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 100),
          ride(
            recordedAt: DateTime(2026, 11, 4, 10),
            caloriesKcal: 50,
            id: '22222222-2222-4222-8222-222222222222',
          ),
        ],
        goal,
        now,
        null,
      ),
      1,
    );
  });

  test('3 日連続達成', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [
          ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 100),
          ride(
            recordedAt: DateTime(2026, 11, 4, 10),
            caloriesKcal: 100,
            id: '22222222-2222-4222-8222-222222222222',
          ),
          ride(
            recordedAt: DateTime(2026, 11, 3, 10),
            caloriesKcal: 100,
            id: '33333333-3333-4333-8333-333333333333',
          ),
        ],
        goal,
        now,
        null,
      ),
      3,
    );
  });

  test('countFrom より前は数えない', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [
          ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 100),
          ride(
            recordedAt: DateTime(2026, 11, 4, 10),
            caloriesKcal: 100,
            id: '22222222-2222-4222-8222-222222222222',
          ),
          ride(
            recordedAt: DateTime(2026, 11, 3, 10),
            caloriesKcal: 100,
            id: '33333333-3333-4333-8333-333333333333',
          ),
        ],
        goal,
        now,
        DateTime(2026, 11, 4),
      ),
      2,
    );
  });

  test('日内複数回で合計達成', () {
    expect(
      ConsecutiveGoalAchievementDays.of(
        [
          ride(recordedAt: DateTime(2026, 11, 5, 10), caloriesKcal: 40),
          ride(
            recordedAt: DateTime(2026, 11, 5, 18),
            caloriesKcal: 60,
            id: '22222222-2222-4222-8222-222222222222',
          ),
        ],
        goal,
        now,
        null,
      ),
      1,
    );
  });
}
