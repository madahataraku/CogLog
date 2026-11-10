import 'package:domain_daily_goal/domain_daily_goal.dart';

/// 読み込んだ一日あたり目標と自動更新設定。
///
/// Example:
/// ```dart
/// const LoadDailyGoalResult(
///   goal: DailyGoal.unset,
///   autoUpdate: DailyGoalAutoUpdateSettings.defaults,
/// );
/// ```
final class LoadDailyGoalResult {
  /// [goal] と [autoUpdate] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const LoadDailyGoalResult(
  ///   goal: DailyGoal.unset,
  ///   autoUpdate: DailyGoalAutoUpdateSettings.defaults,
  /// );
  /// ```
  const LoadDailyGoalResult({required this.goal, required this.autoUpdate});

  /// 保存済み、または未設定の目標。
  final DailyGoal goal;

  /// 自動更新設定。キーが無ければ defaults。
  final DailyGoalAutoUpdateSettings autoUpdate;
}
