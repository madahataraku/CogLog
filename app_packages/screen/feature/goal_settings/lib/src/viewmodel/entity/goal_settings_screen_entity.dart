import 'package:domain_daily_goal/domain_daily_goal.dart';

/// 目標設定画面の入力欄へ一度流し込む文字列と自動更新の UI 値。
///
/// 未設定は空文字。設定済みの 0 は `'0'`。
///
/// Example:
/// ```dart
/// const GoalSettingsScreenEntity(
///   loaded: false,
///   hours: '',
///   minutes: '',
///   seconds: '',
///   calories: '',
///   distance: '',
///   autoUpdateEnabled: false,
///   autoUpdateLevel: DailyGoalAutoUpdateLevel.normal,
/// );
/// ```
final class GoalSettingsScreenEntity {
  /// 読み込み済みフラグ・各欄の初期文字列・自動更新の UI 値を持つ。
  ///
  /// Example:
  /// ```dart
  /// const GoalSettingsScreenEntity(
  ///   loaded: true,
  ///   hours: '0',
  ///   minutes: '0',
  ///   seconds: '0',
  ///   calories: '0.0',
  ///   distance: '0.0',
  ///   autoUpdateEnabled: false,
  ///   autoUpdateLevel: DailyGoalAutoUpdateLevel.normal,
  /// );
  /// ```
  const GoalSettingsScreenEntity({
    required this.loaded,
    required this.hours,
    required this.minutes,
    required this.seconds,
    required this.calories,
    required this.distance,
    required this.autoUpdateEnabled,
    required this.autoUpdateLevel,
  });

  /// 読み込みが成功したあとに true。
  final bool loaded;

  /// 運動時間の時。
  final String hours;

  /// 運動時間の分。
  final String minutes;

  /// 運動時間の秒。
  final String seconds;

  /// 消費カロリー（kcal）。
  final String calories;

  /// 走行距離（km）。
  final String distance;

  /// 目標の自動更新が有効か。
  final bool autoUpdateEnabled;

  /// 自動更新レベル。
  final DailyGoalAutoUpdateLevel autoUpdateLevel;
}
