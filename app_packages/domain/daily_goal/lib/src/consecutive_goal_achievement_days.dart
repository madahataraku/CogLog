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

  /// [now] の現地日付を起点に、目標達成した日が何日分続くかを返す。
  ///
  /// [weeklyAchievementDays] が null のときは暦日連続（本日未達成なら 0）。
  /// 1〜7 のときは達成日の個数を数え、週あたり最大 `7 - m` 日の未達成をスキップできる。
  /// [countFromLocalDate] より前の日は数えない。
  ///
  /// Example:
  /// ```dart
  /// ConsecutiveGoalAchievementDays.of(
  ///   const [],
  ///   const DailyGoal(caloriesKcal: 100),
  ///   DateTime(2026, 11, 5),
  ///   null,
  ///   weeklyAchievementDays: 5,
  /// );
  /// ```
  static int of(
    List<ExerciseHistory> histories,
    DailyGoal goal,
    DateTime now,
    DateTime? countFromLocalDate, {
    int? weeklyAchievementDays,
  }) {
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
    final m = weeklyAchievementDays;
    if (m == null) {
      return _ofCalendarConsecutive(histories, goal, today, countFrom);
    }
    final restBudget = 7 - m;
    var count = 0;
    var cursor = today;
    final skipsByWeekStart = <DateTime, int>{};

    while (true) {
      if (countFrom != null && cursor.isBefore(countFrom)) {
        break;
      }
      final weekStart = _weekStartMonday(cursor);
      final weekEnd = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day + 6,
      );

      if (weekEnd.isBefore(today)) {
        final weekAchieves = _countAchievedInRange(
          histories,
          goal,
          weekStart,
          weekEnd,
        );
        if (weekAchieves < m) {
          break;
        }
      }

      if (_achievedOn(histories, goal, cursor)) {
        count += 1;
      } else {
        final dayBefore = DateTime(cursor.year, cursor.month, cursor.day - 1);
        final pastAchieves = _countAchievedInRange(
          histories,
          goal,
          weekStart,
          dayBefore,
        );
        final remainingInclusive = weekEnd.difference(cursor).inDays + 1;
        final maxPossible = pastAchieves + remainingInclusive;
        if (maxPossible < m) {
          break;
        }
        final skips = skipsByWeekStart[weekStart] ?? 0;
        if (skips + 1 > restBudget) {
          break;
        }
        skipsByWeekStart[weekStart] = skips + 1;
      }
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }

  static int _ofCalendarConsecutive(
    List<ExerciseHistory> histories,
    DailyGoal goal,
    DateTime today,
    DateTime? countFrom,
  ) {
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

  /// [start]〜[end] 両端 inclusive。end が start より前なら 0。
  static int _countAchievedInRange(
    List<ExerciseHistory> histories,
    DailyGoal goal,
    DateTime start,
    DateTime end,
  ) {
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    if (e.isBefore(s)) {
      return 0;
    }
    var n = 0;
    for (var d = s; !d.isAfter(e); d = DateTime(d.year, d.month, d.day + 1)) {
      if (_achievedOn(histories, goal, d)) {
        n += 1;
      }
    }
    return n;
  }

  static DateTime _weekStartMonday(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    final mondayOffset = (date.weekday - DateTime.monday) % 7;
    return DateTime(date.year, date.month, date.day - mondayOffset);
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
