import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

ExerciseHistory ride({
  required DateTime recordedAt,
  required double caloriesKcal,
  required String id,
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

  test('isValidSetting', () {
    expect(WeeklyGoalAchievementDays.isValidSetting(null), isTrue);
    expect(WeeklyGoalAchievementDays.isValidSetting(1), isTrue);
    expect(WeeklyGoalAchievementDays.isValidSetting(7), isTrue);
    expect(WeeklyGoalAchievementDays.isValidSetting(0), isFalse);
    expect(WeeklyGoalAchievementDays.isValidSetting(8), isFalse);
  });

  test('countInWeek は達成日だけ数える', () {
    final histories = [
      ride(
        recordedAt: DateTime(2026, 11, 9, 10),
        caloriesKcal: 100,
        id: '11111111-1111-4111-8111-111111111111',
      ),
      ride(
        recordedAt: DateTime(2026, 11, 11, 10),
        caloriesKcal: 100,
        id: '22222222-2222-4222-8222-222222222222',
      ),
      ride(
        recordedAt: DateTime(2026, 11, 10, 10),
        caloriesKcal: 50,
        id: '33333333-3333-4333-8333-333333333333',
      ),
    ];
    expect(
      WeeklyGoalAchievementDays.countInWeek(
        histories,
        goal,
        DateTime(2026, 11, 11),
      ),
      2,
    );
  });
}
