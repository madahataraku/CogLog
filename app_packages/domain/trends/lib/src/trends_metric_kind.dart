/// 推移グラフに載せる指標の種類。
///
/// 運動は合計集約、身体は区間内の最終計測を使う。
///
/// Example:
/// ```dart
/// TrendsMetricKind.exerciseCaloriesKcal;
/// ```
enum TrendsMetricKind {
  /// 運動時間（分）。[Duration.inMinutes] を double 化して集約する。
  exerciseDurationMinutes,

  /// 走行距離（km）。
  exerciseDistanceKm,

  /// 消費カロリー（kcal）。
  exerciseCaloriesKcal,

  /// 体重（kg）。
  bodyWeightKg,

  /// 体脂肪率（%）。
  bodyFatPercent,

  /// 除脂肪体重（kg）。
  bodyLeanMassKg,
}
