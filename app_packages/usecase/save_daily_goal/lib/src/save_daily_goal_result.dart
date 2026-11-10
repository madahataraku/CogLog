import 'package:domain_daily_goal/domain_daily_goal.dart';

/// 保存できた一日あたり目標と自動更新設定。
///
/// Example:
/// ```dart
/// const SaveDailyGoalResult(
///   goal: DailyGoal.unset,
///   autoUpdate: DailyGoalAutoUpdateSettings.defaults,
/// );
/// ```
final class SaveDailyGoalResult {
  /// 保存した [goal] と [autoUpdate] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const SaveDailyGoalResult(
  ///   goal: DailyGoal.unset,
  ///   autoUpdate: DailyGoalAutoUpdateSettings.defaults,
  /// );
  /// ```
  const SaveDailyGoalResult({required this.goal, required this.autoUpdate});

  /// 保存した目標。
  final DailyGoal goal;

  /// 保存した自動更新設定。
  final DailyGoalAutoUpdateSettings autoUpdate;
}
