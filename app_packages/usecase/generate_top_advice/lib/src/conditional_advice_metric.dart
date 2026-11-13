/// 条件付き定型に埋め込む指標。優先順は距離 → カロリー → 時間。
enum ConditionalAdviceMetric {
  /// 距離（km）。複数候補のとき最優先。
  distance,

  /// 消費カロリー（kcal）。
  calories,

  /// 運動時間。
  duration,
}
