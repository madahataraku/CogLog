import 'package:data_repository_daily_goal_impl/data_repository_daily_goal_impl.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('未保存は unset', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    final goal = await repository.read();
    expect(goal.duration, isNull);
    expect(goal.caloriesKcal, isNull);
    expect(goal.distanceKm, isNull);
  });

  test('0 を書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.write(
      const DailyGoal(duration: Duration.zero, caloriesKcal: 0, distanceKm: 0),
    );

    final goal = await repository.read();
    expect(goal.duration, Duration.zero);
    expect(goal.caloriesKcal, 0);
    expect(goal.distanceKm, 0);
  });

  test('値を書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.write(
      const DailyGoal(
        duration: Duration(hours: 1, minutes: 30, seconds: 15),
        caloriesKcal: 200.5,
        distanceKm: 5.25,
      ),
    );

    final goal = await repository.read();
    expect(goal.duration, const Duration(hours: 1, minutes: 30, seconds: 15));
    expect(goal.caloriesKcal, 200.5);
    expect(goal.distanceKm, 5.25);
  });

  test('null を書くとキーが消える', () async {
    SharedPreferences.setMockInitialValues({
      'daily_goal_duration_seconds': 90,
      'daily_goal_calories_kcal': 100.0,
      'daily_goal_distance_km': 3.0,
    });
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.write(DailyGoal.unset);

    expect(preferences.containsKey('daily_goal_duration_seconds'), isFalse);
    expect(preferences.containsKey('daily_goal_calories_kcal'), isFalse);
    expect(preferences.containsKey('daily_goal_distance_km'), isFalse);

    final goal = await repository.read();
    expect(goal.duration, isNull);
    expect(goal.caloriesKcal, isNull);
    expect(goal.distanceKm, isNull);
  });

  test('自動更新設定の欠落は defaults', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    final settings = await repository.readAutoUpdateSettings();
    expect(settings.enabled, isFalse);
    expect(settings.level, DailyGoalAutoUpdateLevel.normal);
    expect(settings.enabledOnLocalDate, isNull);
  });

  test('自動更新設定を書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.writeAutoUpdateSettings(
      DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.challenging,
        enabledOnLocalDate: DateTime(2026, 11, 5),
        streakEpochLocalDate: DateTime(2026, 11, 6),
        lastAppliedLocalDate: DateTime(2026, 11, 5),
      ),
    );

    final settings = await repository.readAutoUpdateSettings();
    expect(settings.enabled, isTrue);
    expect(settings.level, DailyGoalAutoUpdateLevel.challenging);
    expect(settings.enabledOnLocalDate, DateTime(2026, 11, 5));
    expect(settings.streakEpochLocalDate, DateTime(2026, 11, 6));
    expect(settings.lastAppliedLocalDate, DateTime(2026, 11, 5));
  });

  test('目標と自動更新設定をまとめて書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.writeGoalAndAutoUpdateSettings(
      goal: const DailyGoal(caloriesKcal: 120),
      settings: DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.slow,
        enabledOnLocalDate: DateTime(2026, 11, 5),
      ),
    );

    final goal = await repository.read();
    final settings = await repository.readAutoUpdateSettings();
    expect(goal.caloriesKcal, 120);
    expect(settings.enabled, isTrue);
    expect(settings.level, DailyGoalAutoUpdateLevel.slow);
    expect(settings.enabledOnLocalDate, DateTime(2026, 11, 5));
  });

  test('未設定を二度書いても例外にならない', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesDailyGoalRepository(preferences);

    await repository.write(DailyGoal.unset);
    await repository.write(DailyGoal.unset);

    final goal = await repository.read();
    expect(goal.duration, isNull);
    expect(goal.caloriesKcal, isNull);
    expect(goal.distanceKm, isNull);
  });
}
