import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:usecase_evaluate_daily_goal_auto_update/usecase_evaluate_daily_goal_auto_update.dart';

/// Repository から連続達成を見て目標を上方修正する。
///
/// Example:
/// ```dart
/// EvaluateDailyGoalAutoUpdateUsecaseImpl(
///   goals: goals,
///   histories: histories,
/// ).execute(
///   EvaluateDailyGoalAutoUpdateRequest(now: DateTime(2026, 11, 5)),
/// );
/// ```
final class EvaluateDailyGoalAutoUpdateUsecaseImpl
    implements EvaluateDailyGoalAutoUpdateUsecase {
  /// [goals] と [histories] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// EvaluateDailyGoalAutoUpdateUsecaseImpl(
  ///   goals: goals,
  ///   histories: histories,
  /// );
  /// ```
  const EvaluateDailyGoalAutoUpdateUsecaseImpl({
    required this.goals,
    required this.histories,
  });

  /// 一日あたり目標と自動更新設定。
  final DailyGoalRepository goals;

  /// 運動履歴。
  final ExerciseHistoryRepository histories;

  /// 条件を満たせば目標を書き、満たさなければ何もしない。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   EvaluateDailyGoalAutoUpdateRequest(now: DateTime.timestamp()),
  /// );
  /// ```
  @override
  Future<EvaluateDailyGoalAutoUpdateResult> execute(
    EvaluateDailyGoalAutoUpdateRequest request,
  ) async {
    try {
      final settings = await goals.readAutoUpdateSettings();
      if (!settings.enabled) {
        return const EvaluateDailyGoalAutoUpdateResult(applied: false);
      }
      final local = request.now.toLocal();
      final today = DateTime(local.year, local.month, local.day);
      final lastApplied = settings.lastAppliedLocalDate;
      if (lastApplied != null &&
          lastApplied.year == today.year &&
          lastApplied.month == today.month &&
          lastApplied.day == today.day) {
        return const EvaluateDailyGoalAutoUpdateResult(applied: false);
      }

      final oldGoal = await goals.read();
      final all = await histories.list();
      final consecutive = ConsecutiveGoalAchievementDays.of(
        all,
        oldGoal,
        request.now,
        settings.countFromLocalDate,
      );
      if (consecutive < 3) {
        return const EvaluateDailyGoalAutoUpdateResult(applied: false);
      }

      final newGoal = DailyGoalAutoUpdate.apply(oldGoal, settings.level);
      final nextSettings = settings.copyWith(
        lastAppliedLocalDate: today,
        streakEpochLocalDate: DateTime(today.year, today.month, today.day + 1),
      );
      await goals.write(newGoal);
      try {
        await goals.writeAutoUpdateSettings(nextSettings);
      } on Object {
        await goals.write(oldGoal);
        return const EvaluateDailyGoalAutoUpdateResult(applied: false);
      }
      return EvaluateDailyGoalAutoUpdateResult(applied: true, goal: newGoal);
    } on Object {
      return const EvaluateDailyGoalAutoUpdateResult(applied: false);
    }
  }
}
