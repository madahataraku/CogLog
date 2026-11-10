import 'package:domain_daily_goal/domain_daily_goal.dart';

/// 保存する一日あたり目標と自動更新の UI 入力。
///
/// Example:
/// ```dart
/// SaveDailyGoalRequest(
///   goal: DailyGoal.unset,
///   autoUpdateEnabled: false,
///   autoUpdateLevel: DailyGoalAutoUpdateLevel.normal,
///   now: DateTime(2026, 11, 5),
/// );
/// ```
final class SaveDailyGoalRequest {
  /// 目標・自動更新フラグ・レベル・基準時刻を持つ依頼を作る。
  ///
  /// Example:
  /// ```dart
  /// SaveDailyGoalRequest(
  ///   goal: DailyGoal.unset,
  ///   autoUpdateEnabled: false,
  ///   autoUpdateLevel: DailyGoalAutoUpdateLevel.normal,
  ///   now: DateTime.timestamp(),
  /// );
  /// ```
  const SaveDailyGoalRequest({
    required this.goal,
    required this.autoUpdateEnabled,
    required this.autoUpdateLevel,
    required this.now,
  });

  /// 保存する目標。
  final DailyGoal goal;

  /// 自動更新を有効にするか。
  final bool autoUpdateEnabled;

  /// 自動更新レベル。
  final DailyGoalAutoUpdateLevel autoUpdateLevel;

  /// 日付判定の基準時刻。
  final DateTime now;
}
