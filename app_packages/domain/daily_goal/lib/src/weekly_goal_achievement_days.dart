import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'daily_goal.dart';
import 'daily_goal_day_achievement.dart';

/// 週間の目標達成日数の集計と設定値の妥当性。
///
/// Example:
/// ```dart
/// WeeklyGoalAchievementDays.isValidSetting(3);
/// ```
final class WeeklyGoalAchievementDays {
  /// 計算用の名前空間。
  const WeeklyGoalAchievementDays._();

  /// [value] が未設定または 1〜7 なら true。
  ///
  /// Example:
  /// ```dart
  /// WeeklyGoalAchievementDays.isValidSetting(null);
  /// ```
  static bool isValidSetting(int? value) =>
      value == null || (value >= 1 && value <= 7);

  /// [weekAnchor] を含む月曜始まり週の達成日数。
  ///
  /// Example:
  /// ```dart
  /// WeeklyGoalAchievementDays.countInWeek(
  ///   const [],
  ///   DailyGoal.unset,
  ///   DateTime(2026, 11, 11),
  /// );
  /// ```
  static int countInWeek(
    List<ExerciseHistory> histories,
    DailyGoal goal,
    DateTime weekAnchor,
  ) {
    final week = PeriodWindow.week(weekAnchor);
    final start = DateTime(week.start.year, week.start.month, week.start.day);
    var count = 0;
    for (var i = 0; i < 7; i++) {
      final day = DateTime(start.year, start.month, start.day + i);
      if (_achievedOn(histories, goal, day)) {
        count += 1;
      }
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
