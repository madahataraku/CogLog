import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'daily_goal.dart';
import 'goal_metric_achievement.dart';
import 'goal_metric_status.dart';

/// 1 日分の合計が、設定済みかつ正の目標をすべて達成しているか。
///
/// Example:
/// ```dart
/// DailyGoalDayAchievement.isAchieved(
///   const DailyGoal(caloriesKcal: 100),
///   const PeriodAggregate(
///     count: 1,
///     distanceKm: 0,
///     caloriesKcal: 100,
///     duration: Duration.zero,
///   ),
/// );
/// ```
final class DailyGoalDayAchievement {
  /// 計算用の名前空間。
  const DailyGoalDayAchievement._();

  /// [goal] の正の指標がすべて実績以上なら true。
  ///
  /// 正の目標が 1 つも無ければ false。0・未設定は無視する。
  ///
  /// Example:
  /// ```dart
  /// DailyGoalDayAchievement.isAchieved(DailyGoal.unset, PeriodAggregate.empty);
  /// ```
  static bool isAchieved(DailyGoal goal, PeriodAggregate day) {
    var hasPositive = false;
    final durationGoal = goal.duration;
    if (durationGoal != null && durationGoal > Duration.zero) {
      hasPositive = true;
      final achievement = GoalMetricAchievement.ofDuration(
        goal: durationGoal,
        actual: day.duration,
      );
      if (achievement.status != GoalMetricStatus.ratio ||
          (achievement.ratio ?? 0) < 1) {
        return false;
      }
    }
    final caloriesGoal = goal.caloriesKcal;
    if (caloriesGoal != null && caloriesGoal > 0) {
      hasPositive = true;
      final achievement = GoalMetricAchievement.ofNullable(
        goal: caloriesGoal,
        actual: day.caloriesKcal,
      );
      if (achievement.status != GoalMetricStatus.ratio ||
          (achievement.ratio ?? 0) < 1) {
        return false;
      }
    }
    final distanceGoal = goal.distanceKm;
    if (distanceGoal != null && distanceGoal > 0) {
      hasPositive = true;
      final achievement = GoalMetricAchievement.ofNullable(
        goal: distanceGoal,
        actual: day.distanceKm,
      );
      if (achievement.status != GoalMetricStatus.ratio ||
          (achievement.ratio ?? 0) < 1) {
        return false;
      }
    }
    return hasPositive;
  }
}
