import 'daily_goal_auto_update_level.dart';

/// 目標の自動更新の永続設定。
///
/// 日付フィールドは現地日付の年月日のみを意味する（時刻は使わない）。
///
/// Example:
/// ```dart
/// DailyGoalAutoUpdateSettings.defaults;
/// ```
final class DailyGoalAutoUpdateSettings {
  /// 有効フラグ・レベル・起算日を持つ。
  ///
  /// Example:
  /// ```dart
  /// const DailyGoalAutoUpdateSettings(
  ///   enabled: true,
  ///   level: DailyGoalAutoUpdateLevel.normal,
  /// );
  /// ```
  const DailyGoalAutoUpdateSettings({
    required this.enabled,
    required this.level,
    this.enabledOnLocalDate,
    this.streakEpochLocalDate,
    this.lastAppliedLocalDate,
  });

  /// 無効・ふつう・日付なし。
  static const defaults = DailyGoalAutoUpdateSettings(
    enabled: false,
    level: DailyGoalAutoUpdateLevel.normal,
  );

  /// 自動更新が有効か。
  final bool enabled;

  /// 上方修正の強さ。
  final DailyGoalAutoUpdateLevel level;

  /// 有効化した現地日付。無効時は null。
  final DateTime? enabledOnLocalDate;

  /// 連続達成の起算日。この日より前は数えない。
  final DateTime? streakEpochLocalDate;

  /// 直近で上方修正した現地日付。同一日の再適用防止に使う。
  final DateTime? lastAppliedLocalDate;

  /// 連続達成の数え始め（enabledOn と streakEpoch の遅い方）。
  ///
  /// Example:
  /// ```dart
  /// DailyGoalAutoUpdateSettings.defaults.countFromLocalDate;
  /// ```
  DateTime? get countFromLocalDate {
    final enabledOn = enabledOnLocalDate;
    final epoch = streakEpochLocalDate;
    if (enabledOn == null) {
      return epoch;
    }
    if (epoch == null) {
      return enabledOn;
    }
    return enabledOn.isAfter(epoch) ? enabledOn : epoch;
  }

  /// 日付以外を差し替えたコピーを返す。
  ///
  /// Example:
  /// ```dart
  /// DailyGoalAutoUpdateSettings.defaults.copyWith(enabled: true);
  /// ```
  DailyGoalAutoUpdateSettings copyWith({
    bool? enabled,
    DailyGoalAutoUpdateLevel? level,
    DateTime? enabledOnLocalDate,
    DateTime? streakEpochLocalDate,
    DateTime? lastAppliedLocalDate,
    bool clearEnabledOnLocalDate = false,
    bool clearStreakEpochLocalDate = false,
    bool clearLastAppliedLocalDate = false,
  }) {
    return DailyGoalAutoUpdateSettings(
      enabled: enabled ?? this.enabled,
      level: level ?? this.level,
      enabledOnLocalDate: clearEnabledOnLocalDate
          ? null
          : (enabledOnLocalDate ?? this.enabledOnLocalDate),
      streakEpochLocalDate: clearStreakEpochLocalDate
          ? null
          : (streakEpochLocalDate ?? this.streakEpochLocalDate),
      lastAppliedLocalDate: clearLastAppliedLocalDate
          ? null
          : (lastAppliedLocalDate ?? this.lastAppliedLocalDate),
    );
  }
}
