import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:test/test.dart';

void main() {
  const day = PeriodAggregate(
    count: 1,
    distanceKm: 5,
    caloriesKcal: 200,
    duration: Duration(minutes: 30),
  );

  test('正の目標がすべて達成なら true', () {
    expect(
      DailyGoalDayAchievement.isAchieved(
        const DailyGoal(
          duration: Duration(minutes: 30),
          caloriesKcal: 200,
          distanceKm: 5,
        ),
        day,
      ),
      isTrue,
    );
  });

  test('正の目標が無い（未設定のみ）なら false', () {
    expect(DailyGoalDayAchievement.isAchieved(DailyGoal.unset, day), isFalse);
  });

  test('正の目標が無い（0 のみ）なら false', () {
    expect(
      DailyGoalDayAchievement.isAchieved(
        const DailyGoal(
          duration: Duration.zero,
          caloriesKcal: 0,
          distanceKm: 0,
        ),
        day,
      ),
      isFalse,
    );
  });

  test('正と未設定の混在で正だけ達成なら true', () {
    expect(
      DailyGoalDayAchievement.isAchieved(
        const DailyGoal(caloriesKcal: 200),
        day,
      ),
      isTrue,
    );
  });

  test('正の目標が未達なら false', () {
    expect(
      DailyGoalDayAchievement.isAchieved(
        const DailyGoal(caloriesKcal: 300),
        day,
      ),
      isFalse,
    );
  });
}
