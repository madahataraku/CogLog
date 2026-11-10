import 'package:domain_daily_goal/domain_daily_goal.dart';

/// 目標設定画面が持つ永続済みの一日あたり目標と自動更新の UI 入力。
///
/// [loaded] が false のあいだは保存を受け付けない。編集下書きは持たない。
///
/// Example:
/// ```dart
/// GoalSettingsScreenState.initial;
/// ```
final class GoalSettingsScreenState {
  /// 読み込み済みフラグ・[goal]・自動更新の UI 値を持つ。
  ///
  /// Example:
  /// ```dart
  /// GoalSettingsScreenState.initial;
  /// ```
  const GoalSettingsScreenState({
    required this.loaded,
    required this.goal,
    required this.autoUpdateEnabled,
    required this.autoUpdateLevel,
  });

  /// まだ読み込んでいない状態。目標は未設定、自動更新は初期値。
  static const initial = GoalSettingsScreenState(
    loaded: false,
    goal: DailyGoal.unset,
    autoUpdateEnabled: false,
    autoUpdateLevel: DailyGoalAutoUpdateLevel.normal,
  );

  /// 読み込みが成功したあとに true。
  final bool loaded;

  /// 永続化されている一日あたり目標。
  final DailyGoal goal;

  /// 目標の自動更新が有効か。
  final bool autoUpdateEnabled;

  /// 自動更新レベル。
  final DailyGoalAutoUpdateLevel autoUpdateLevel;
}
