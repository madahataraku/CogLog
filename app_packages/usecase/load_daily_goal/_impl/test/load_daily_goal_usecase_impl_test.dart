import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:test/test.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';
import 'package:usecase_load_daily_goal_impl/usecase_load_daily_goal_impl.dart';

void main() {
  test('未保存のときは未設定を返す', () async {
    final result = await LoadDailyGoalUsecaseImpl(
      goals: MemoryDailyGoalRepository(),
    ).execute(const LoadDailyGoalRequest());

    expect(result.goal.duration, isNull);
    expect(result.goal.caloriesKcal, isNull);
    expect(result.goal.distanceKm, isNull);
    expect(result.autoUpdate.enabled, isFalse);
    expect(result.autoUpdate.level, DailyGoalAutoUpdateLevel.normal);
  });

  test('保存した目標を再び読む', () async {
    final goals = MemoryDailyGoalRepository();
    const saved = DailyGoal(
      duration: Duration.zero,
      caloriesKcal: 0,
      distanceKm: 5,
    );
    await goals.write(saved);

    final result = await LoadDailyGoalUsecaseImpl(goals: goals)
        .execute(const LoadDailyGoalRequest());

    expect(result.goal.duration, Duration.zero);
    expect(result.goal.caloriesKcal, 0);
    expect(result.goal.distanceKm, 5);
  });
}
