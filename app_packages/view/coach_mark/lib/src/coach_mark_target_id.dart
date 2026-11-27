/// ハイライト対象の識別子。画面横断で一意。
///
/// Example:
/// ```dart
/// CoachMarkTargetId.homePeriodTotals;
/// ```
enum CoachMarkTargetId {
  /// ホーム: 本文全体。
  homeBody,

  /// ホーム: アドバイザーイラスト（メイン導入）。
  homeAdvisor,

  /// ホーム: 期間集計と指標切替の外カード（メイン段階1）。
  homePeriodTotals,

  /// ホーム: 目標達成率と週間達成の外カード（メイン段階2）。
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

  /// 目標設定: 週間の目標運動日数。
  goalWeeklyDays,

  /// 目標設定: 自動更新スイッチとレベル。
  goalAutoUpdate,

  /// 撮影: カメラプレビュー／権限案内領域。
  meterCameraArea,

  /// 撮影結果: 計測入力グループ。
  meterEditFields,

  /// 推移: グラフ領域。
  trendsChart,

  /// 運動履歴: カレンダースタンプ領域。
  historyCalendar,

  /// アチーブメント: 一覧の先頭行。
  achievementList,
}
