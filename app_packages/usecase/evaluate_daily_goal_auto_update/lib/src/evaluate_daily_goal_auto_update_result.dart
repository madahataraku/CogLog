import 'package:domain_daily_goal/domain_daily_goal.dart';

/// 自動更新判定の結果。
///
/// Example:
/// ```dart
/// const EvaluateDailyGoalAutoUpdateResult(applied: false);
/// ```
final class EvaluateDailyGoalAutoUpdateResult {
  /// [applied] と任意の新しい [goal] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const EvaluateDailyGoalAutoUpdateResult(applied: false);
  /// ```
  const EvaluateDailyGoalAutoUpdateResult({required this.applied, this.goal});

  /// 上方修正を適用したか。
  final bool applied;

  /// 適用時の新しい目標。未適用なら null。
  final DailyGoal? goal;
}
