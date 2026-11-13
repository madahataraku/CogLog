/// 条件付きワンポイントアドバイス定型の種類。
///
/// 選択の優先順位は generate_top_advice の Selector 実装が決める。値の並びは識別用。
enum ConditionalAdviceKind {
  /// いずれかの正目標指標が 300% を超えた。
  over300,

  /// いずれかが 200% を超えた（300% 超は [over300]）。
  over200,

  /// 連続目標達成日数が 2 日以上。
  streakGoals,

  /// 正目標が 1 件以上あり、すべて 100%〜200% の範囲。
  allPerfect,

  /// 正目標がちょうど 3 件で 2 件達成（未達 1 件の指標を埋め込む）。
  twoAchieved,

  /// 正目標がちょうど 3 件で 1 件達成（達成 1 件の指標を埋め込む）。
  oneAchieved,

  /// 1 指標だけ 80%〜100% 未満で他は 100% 以上（その指標を埋め込む）。
  nearMissLow,

  /// 直前運動日からの空白が 7 日以上。
  welcomeBack,

  /// 正目標が 1 件もない。
  noPositiveGoal,
}
