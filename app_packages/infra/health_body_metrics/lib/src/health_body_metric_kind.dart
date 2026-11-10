/// ヘルスから読む身体指標の種類。
///
/// Example:
/// ```dart
/// HealthBodyMetricKind.weightKg;
/// ```
enum HealthBodyMetricKind {
  /// 体重（kg）。
  weightKg,

  /// 体脂肪率（%）。
  bodyFatPercent,

  /// 除脂肪体重（kg）。
  leanMassKg,
}
