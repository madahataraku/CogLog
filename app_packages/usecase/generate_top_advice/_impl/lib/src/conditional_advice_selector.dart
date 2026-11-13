import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

/// 条件付きワンポイントアドバイス定型の判定。
///
/// 優先順位は要件の ID 順。非該当時は null（既存フォールバック乱数へ）。
///
/// Example:
/// ```dart
/// ConditionalAdviceSelector.select(
///   achievement: achievement,
///   goal: goal,
///   consecutiveGoalAchievementDays: 2,
///   daysSincePreviousExerciseDay: null,
/// );
/// ```
final class ConditionalAdviceSelector {
  const ConditionalAdviceSelector._();

  /// 目標達成と連続達成・運動空白から条件付き定型を 1 件選ぶ。
  ///
  /// Example:
  /// ```dart
  /// ConditionalAdviceSelector.select(
  ///   achievement: achievement,
  ///   goal: goal,
  ///   consecutiveGoalAchievementDays: 0,
  ///   daysSincePreviousExerciseDay: 7,
  /// );
  /// ```
  static ConditionalAdviceSelection? select({
    required GoalAchievement achievement,
    required DailyGoal goal,
    required int consecutiveGoalAchievementDays,
    required int? daysSincePreviousExerciseDay,
  }) {
    final positive = _positiveMetrics(achievement, goal);
    if (positive.any((e) => e.ratio > 3.0)) {
      return const ConditionalAdviceSelection(
        kind: ConditionalAdviceKind.over300,
      );
    }
    if (positive.any((e) => e.ratio > 2.0)) {
      return const ConditionalAdviceSelection(
        kind: ConditionalAdviceKind.over200,
      );
    }
    if (consecutiveGoalAchievementDays >= 2) {
      return const ConditionalAdviceSelection(
        kind: ConditionalAdviceKind.streakGoals,
      );
    }
    if (positive.isNotEmpty &&
        positive.every((e) => e.ratio >= 1.0 && e.ratio <= 2.0)) {
      return const ConditionalAdviceSelection(
        kind: ConditionalAdviceKind.allPerfect,
      );
    }
    if (positive.length == 3) {
      final achieved = positive
          .where((e) => e.ratio >= 1.0)
          .map((e) => e.metric)
          .toList();
      final unachieved = positive
          .where((e) => e.ratio < 1.0)
          .map((e) => e.metric)
          .toList();
      if (achieved.length == 2 && unachieved.length == 1) {
        return ConditionalAdviceSelection(
          kind: ConditionalAdviceKind.twoAchieved,
          metric: _firstByPriority(unachieved),
        );
      }
      if (achieved.length == 1) {
        return ConditionalAdviceSelection(
          kind: ConditionalAdviceKind.oneAchieved,
          metric: _firstByPriority(achieved),
        );
      }
    }
    final nearMiss = positive
        .where((e) => e.ratio >= 0.8 && e.ratio < 1.0)
        .toList();
    if (nearMiss.length == 1) {
      final candidate = nearMiss.single;
      final othersMet = positive.every(
        (e) => e.metric == candidate.metric || e.ratio >= 1.0,
      );
      if (othersMet) {
        return ConditionalAdviceSelection(
          kind: ConditionalAdviceKind.nearMissLow,
          metric: candidate.metric,
        );
      }
    }
    if (daysSincePreviousExerciseDay != null &&
        daysSincePreviousExerciseDay >= 7) {
      return const ConditionalAdviceSelection(
        kind: ConditionalAdviceKind.welcomeBack,
      );
    }
    if (positive.isEmpty) {
      return const ConditionalAdviceSelection(
        kind: ConditionalAdviceKind.noPositiveGoal,
      );
    }
    return null;
  }

  static List<_PositiveMetric> _positiveMetrics(
    GoalAchievement achievement,
    DailyGoal goal,
  ) {
    final list = <_PositiveMetric>[];
    void add(
      ConditionalAdviceMetric metric,
      GoalMetricAchievement value,
      bool hasPositiveGoal,
    ) {
      if (!hasPositiveGoal) {
        return;
      }
      if (value.status == GoalMetricStatus.ratio && value.ratio != null) {
        list.add(_PositiveMetric(metric: metric, ratio: value.ratio!));
      }
    }

    add(
      ConditionalAdviceMetric.distance,
      achievement.distance,
      goal.hasDistance && goal.distanceKm! > 0,
    );
    add(
      ConditionalAdviceMetric.calories,
      achievement.calories,
      goal.hasCalories && goal.caloriesKcal! > 0,
    );
    add(
      ConditionalAdviceMetric.duration,
      achievement.duration,
      goal.hasDuration && goal.duration! > Duration.zero,
    );
    return list;
  }

  static ConditionalAdviceMetric _firstByPriority(
    Iterable<ConditionalAdviceMetric> metrics,
  ) {
    for (final priority in ConditionalAdviceMetric.values) {
      if (metrics.contains(priority)) {
        return priority;
      }
    }
    throw StateError('metric 候補が空');
  }
}

final class _PositiveMetric {
  const _PositiveMetric({required this.metric, required this.ratio});

  final ConditionalAdviceMetric metric;
  final double ratio;
}
