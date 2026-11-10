import '../entity/goal_settings_screen_entity.dart';
import '../state/goal_settings_screen_state.dart';

/// 目標設定の State を入力欄の初期文字列へ変える。
///
/// Example:
/// ```dart
/// const GoalSettingsStateToEntityDelegate().execute(
///   GoalSettingsScreenState.initial,
/// );
/// ```
final class GoalSettingsStateToEntityDelegate {
  /// 変換を作る。
  ///
  /// Example:
  /// ```dart
  /// const GoalSettingsStateToEntityDelegate();
  /// ```
  const GoalSettingsStateToEntityDelegate();

  /// [state] の目標と自動更新を、未設定は空・設定済みは数値文字にする。
  ///
  /// Example:
  /// ```dart
  /// const GoalSettingsStateToEntityDelegate().execute(
  ///   GoalSettingsScreenState.initial,
  /// );
  /// ```
  GoalSettingsScreenEntity execute(GoalSettingsScreenState state) {
    final goal = state.goal;
    final duration = goal.duration;
    return GoalSettingsScreenEntity(
      loaded: state.loaded,
      hours: duration == null ? '' : '${duration.inHours}',
      minutes: duration == null ? '' : '${duration.inMinutes.remainder(60)}',
      seconds: duration == null ? '' : '${duration.inSeconds.remainder(60)}',
      calories: _optionalNumber(goal.caloriesKcal),
      distance: _optionalNumber(goal.distanceKm),
      autoUpdateEnabled: state.autoUpdateEnabled,
      autoUpdateLevel: state.autoUpdateLevel,
    );
  }

  /// 未設定は空、設定済みは [toString] の結果。
  ///
  /// Example:
  /// ```dart
  /// _optionalNumber(null);
  /// ```
  String _optionalNumber(double? value) => value == null ? '' : '$value';
}
