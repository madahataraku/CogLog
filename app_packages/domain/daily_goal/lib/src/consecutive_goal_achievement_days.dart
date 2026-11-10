import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'daily_goal.dart';
import 'daily_goal_day_achievement.dart';

/// 連続目標達成日数の算出。
///
/// Example:
/// ```dart
/// ConsecutiveGoalAchievementDays.of(
///   const [],
///   DailyGoal.unset,
///   DateTime(2026, 11, 5),
///   null,
/// );
/// ```
final class ConsecutiveGoalAchievementDays {
  /// 計算用の名前空間。
  const ConsecutiveGoalAchievementDays._();

  /// [now] の現地日付を起点に、目標達成した日が何日連続しているかを返す。
  ///
  /// 本日未達成なら 0。[countFromLocalDate] より前の日は数えない。
  ///
  /// Example:
  /// ```dart
  /// ConsecutiveGoalAchievementDays.of(
  ///   const [],
  ///   const DailyGoal(caloriesKcal: 100),
  ///   DateTime(2026, 11, 5),
  ///   null,
  /// );
  /// ```
  static int of(
    List<ExerciseHistory> histories,
    DailyGoal goal,
    DateTime now,
    DateTime? countFromLocalDate,
  ) {
    final local = now.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    final countFrom = countFromLocalDate == null
        ? null
        : DateTime(
            countFromLocalDate.year,
            countFromLocalDate.month,
            countFromLocalDate.day,
          );
    if (countFrom != null && today.isBefore(countFrom)) {
      return 0;
    }
    if (!_achievedOn(histories, goal, today)) {
      return 0;
    }
    var count = 0;
    var cursor = today;
    while (true) {
      if (countFrom != null && cursor.isBefore(countFrom)) {
        break;
      }
      if (!_achievedOn(histories, goal, cursor)) {
        break;
      }
      count += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }

  static bool _achievedOn(
    List<ExerciseHistory> histories,
    DailyGoal goal,
    DateTime day,
  ) {
    final window = PeriodWindow.today(day);
    final aggregate = PeriodAggregate.of(histories, window);
    return DailyGoalDayAchievement.isAchieved(goal, aggregate);
  }
}
