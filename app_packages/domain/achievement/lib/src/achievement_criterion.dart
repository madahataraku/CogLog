/// アチーブメント達成条件の種別。
///
/// 評価器が運動履歴から進捗を算出するときの分岐に使う。
///
/// Example:
/// ```dart
/// final criterion = AchievementCriterion.firstRecord;
/// ```
enum AchievementCriterion {
  /// 初回の運動記録登録。
  firstRecord,

  /// 史上最長の連続運動日数。
  maxStreakDays,

  /// ユニークな運動日の累計。
  uniqueDays,

  /// 累計走行距離（km）。
  totalDistanceKm,

  /// 累計運動時間（秒）。
  totalDuration,

  /// 累計消費カロリー（kcal）。
  totalCaloriesKcal,

  /// 1 回の運動時間（秒）。
  singleDuration,

  /// 過去最高走行距離の更新（初回は対象外）。
  bestDistanceUpdate,

  /// 過去最高運動時間の更新（初回は対象外）。
  bestDurationUpdate,

  /// 隣接する運動日間隔が目標日数を超えた再開。
  gapRestartDays,

  /// うるう日（2/29）の運動。
  leapDay,

  /// 11 月 11 日の運動。
  dayMonth1111,

  /// 運動記録の総件数。
  recordCount,

  /// 同一日の最大運動回数。
  maxSameDayCount,

  /// 年末年始シーズン（12/29–1/3）の運動日数。
  yearEndNewYearSeason,
}
