/// グループ内で同時表示する指標の組。
///
/// 運動は 1 指標、身体は kg 組または体脂肪率。
///
/// Example:
/// ```dart
/// TrendsMetricSet.exerciseCalories;
/// ```
enum TrendsMetricSet {
  /// 消費カロリー（運動の初期選択）。
  exerciseCalories,

  /// 運動時間。
  exerciseDuration,

  /// 走行距離。
  exerciseDistance,

  /// 体重と除脂肪体重（身体の初期選択）。
  bodyKgPair,

  /// 体脂肪率。
  bodyFat,
}
