/// 目標の自動更新の強さ。
///
/// Example:
/// ```dart
/// DailyGoalAutoUpdateLevel.normal.multiplier;
/// ```
enum DailyGoalAutoUpdateLevel {
  /// ゆっくり（1.05 倍）。
  slow,

  /// ふつう（1.1 倍）。
  normal,

  /// 挑戦的（1.25 倍）。
  challenging,
}

/// [DailyGoalAutoUpdateLevel] の倍率。
extension DailyGoalAutoUpdateLevelMultiplier on DailyGoalAutoUpdateLevel {
  /// 上方修正に使う倍率。
  ///
  /// Example:
  /// ```dart
  /// DailyGoalAutoUpdateLevel.slow.multiplier;
  /// ```
  double get multiplier => switch (this) {
    DailyGoalAutoUpdateLevel.slow => 1.05,
    DailyGoalAutoUpdateLevel.normal => 1.1,
    DailyGoalAutoUpdateLevel.challenging => 1.25,
  };
}
