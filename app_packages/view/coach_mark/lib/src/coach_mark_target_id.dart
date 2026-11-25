/// ハイライト対象の識別子。画面横断で一意。
///
/// Example:
/// ```dart
/// CoachMarkTargetId.homePeriodTotals;
/// ```
enum CoachMarkTargetId {
  /// ホーム: 指標切替。
  homeMetricSelect,

  /// ホーム: 期間合計ブロック。
  homePeriodTotals,

  /// ホーム: 目標達成リング。
  homeGoalRings,

  /// ホーム: アチーブメント（trophy）。
  homeAchievementTrophy,

  /// ボトムナビ: ホーム。
  navHome,

  /// ボトムナビ: メーター記録。
  navMeterCapture,

  /// ボトムナビ: 推移。
  navTrends,

  /// ボトムナビ: 運動履歴。
  navExerciseHistory,

  /// ボトムナビ: 目標設定。
  navGoalSettings,

  /// 目標設定: 一日あたり入力グループ。
  goalDailyInputs,

  /// 撮影: カメラプレビュー／権限案内領域。
  meterCameraArea,

  /// 撮影結果: 計測入力グループ。
  meterEditFields,

  /// 推移: グラフ領域。
  trendsChart,

  /// 運動履歴: カレンダースタンプ領域。
  historyCalendar,
}
