/// メイン導線の段階（表示中は session。到達段階は [TutorialProgress.mainReachedStep]）。
///
/// Example:
/// ```dart
/// TutorialMainStep.homeIntro;
/// ```
enum TutorialMainStep {
  /// 段階1: ホーム画面の見かた（期間合計と指標切替）。
  homeIntro,

  /// 段階2: 目標進捗率の見かた。
  goalProgressIntro,

  /// 段階3: 目標設定誘導。
  goalRecommend,

  /// 段階4: メーター記録案内。
  meterRecommend,

  /// 段階5: 推移案内。
  trendsRecommend,

  /// 段階6: 運動履歴案内。
  historyRecommend,

  /// 段階7: アチーブメント案内（閉じるとメイン完了）。
  achievementRecommend,
}
