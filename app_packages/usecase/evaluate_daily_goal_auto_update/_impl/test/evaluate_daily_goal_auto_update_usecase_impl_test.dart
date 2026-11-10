import 'dart:typed_data';

import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:test/test.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';
import 'package:usecase_evaluate_daily_goal_auto_update_impl/usecase_evaluate_daily_goal_auto_update_impl.dart';

void main() {
  final now = DateTime(2026, 11, 5, 15);
  final photo = Uint8List.fromList([1]);

  test('無効なら適用しない', () async {
    final goals = MemoryDailyGoalRepository();
    await goals.write(const DailyGoal(caloriesKcal: 100));
    final histories = MemoryExerciseHistoryRepository();
    final result = await EvaluateDailyGoalAutoUpdateUsecaseImpl(
      goals: goals,
      histories: histories,
    ).execute(EvaluateDailyGoalAutoUpdateRequest(now: now));
    expect(result.applied, isFalse);
  });

  test('3 日連続達成で上方修正する', () async {
    final goals = MemoryDailyGoalRepository();
    await goals.write(const DailyGoal(caloriesKcal: 100));
    await goals.writeAutoUpdateSettings(
      DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.slow,
        enabledOnLocalDate: DateTime(2026, 11, 1),
      ),
    );
    final histories = MemoryExerciseHistoryRepository();
    for (final day in [
      DateTime(2026, 11, 5, 10),
      DateTime(2026, 11, 4, 10),
      DateTime(2026, 11, 3, 10),
    ]) {
      await histories.create(
        creationStartedAt: day,
        capturedAt: day,
        recordedAt: day,
        recordedAtManuallySet: false,
        distanceKm: 1,
        duration: const Duration(minutes: 30),
        caloriesKcal: 100,
        averageSpeedKmh: 1,
        photoBytes: photo,
      );
    }

    final result = await EvaluateDailyGoalAutoUpdateUsecaseImpl(
      goals: goals,
      histories: histories,
    ).execute(EvaluateDailyGoalAutoUpdateRequest(now: now));

    expect(result.applied, isTrue);
    expect(result.goal?.caloriesKcal, 105);
    final settings = await goals.readAutoUpdateSettings();
    expect(settings.lastAppliedLocalDate, DateTime(2026, 11, 5));
    expect(settings.streakEpochLocalDate, DateTime(2026, 11, 6));

    final again = await EvaluateDailyGoalAutoUpdateUsecaseImpl(
      goals: goals,
      histories: histories,
    ).execute(EvaluateDailyGoalAutoUpdateRequest(now: now));
    expect(again.applied, isFalse);
  });
}
