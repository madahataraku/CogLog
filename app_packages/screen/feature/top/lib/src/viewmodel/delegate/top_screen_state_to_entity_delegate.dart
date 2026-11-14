import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';

import '../entity/top_goal_ring_entity.dart';
import '../entity/top_screen_entity.dart';
import '../state/top_screen_state.dart';

/// トップ画面の State を表示用の文字列へ変える。
///
/// Example:
/// ```dart
/// const TopScreenStateToEntityDelegate().execute(TopScreenState.initial);
/// ```
final class TopScreenStateToEntityDelegate {
  /// 変換を作る。
  ///
  /// Example:
  /// ```dart
  /// const TopScreenStateToEntityDelegate();
  /// ```
  const TopScreenStateToEntityDelegate();

  /// [state] の合計・目標達成・アドバイス本文とトーンを、選ばれている指標の表記にする。
  ///
  /// Example:
  /// ```dart
  /// const TopScreenStateToEntityDelegate().execute(TopScreenState.initial);
  /// ```
  TopScreenEntity execute(TopScreenState state) {
    final achievement = GoalAchievement.of(state.goal, state.today);
    return TopScreenEntity(
      metric: state.metric,
      todayText: PeriodTotalText.of(
        aggregate: state.today,
        metric: state.metric,
      ),
      weekText: PeriodTotalText.of(aggregate: state.week, metric: state.metric),
      monthText: PeriodTotalText.of(
        aggregate: state.month,
        metric: state.metric,
      ),
      adviceText: state.adviceText,
      adviceTone: state.adviceTone,
      pendingModelDownloadGuidance: state.pendingModelDownloadGuidance,
      pendingGemmaMeterGuidance: state.pendingGemmaMeterGuidance,
      hasNewAchievements: state.hasNewAchievements,
      duration: _ring(
        achievement: achievement.duration,
        actualText: PeriodTotalText.duration(state.today.duration),
        goalText: state.goal.duration == null
            ? ''
            : PeriodTotalText.duration(state.goal.duration!),
      ),
      calories: _ring(
        achievement: achievement.calories,
        actualText: PeriodTotalText.oneDecimal(state.today.caloriesKcal),
        goalText: state.goal.caloriesKcal == null
            ? ''
            : PeriodTotalText.oneDecimal(state.goal.caloriesKcal!),
      ),
      distance: _ring(
        achievement: achievement.distance,
        actualText: PeriodTotalText.oneDecimal(state.today.distanceKm),
        goalText: state.goal.distanceKm == null
            ? ''
            : PeriodTotalText.oneDecimal(state.goal.distanceKm!),
      ),
    );
  }

  /// [achievement] と実績・目標表記からリング用 Entity を作る。
  ///
  /// Example:
  /// ```dart
  /// _ring(
  ///   achievement: achievement.calories,
  ///   actualText: '300.0',
  ///   goalText: '200.0',
  /// );
  /// ```
  TopGoalRingEntity _ring({
    required GoalMetricAchievement achievement,
    required String actualText,
    required String goalText,
  }) {
    final ratio = achievement.ratio;
    final percentText = switch (achievement.status) {
      GoalMetricStatus.unset => '',
      GoalMetricStatus.zeroGoal => '0%',
      GoalMetricStatus.ratio => '${(ratio! * 100).round()}%',
    };
    return TopGoalRingEntity(
      status: achievement.status,
      lap1: achievement.lap1,
      lap2: achievement.lap2,
      percentText: percentText,
      actualText: achievement.status == GoalMetricStatus.unset
          ? ''
          : actualText,
      goalText: achievement.status == GoalMetricStatus.unset ? '' : goalText,
    );
  }
}
