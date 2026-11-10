/// 推移の集計期間。
enum TrendsPeriod {
  /// 過去 30 日（本日含む）。
  days30,

  /// 過去 90 日。
  days90,

  /// 過去 182 日。
  days182,

  /// 過去 365 日。
  days365,
}

/// 推移の指標グループ。
enum TrendsMetricGroup {
  /// 運動時間・走行距離・消費カロリー。
  exercise,

  /// 体重・体脂肪率・除脂肪体重。
  body,
}

/// 推移画面が持つ選択中の期間とグループ。
///
/// Example:
/// ```dart
/// TrendsScreenState.initial;
/// ```
final class TrendsScreenState {
  /// [period] と [group] を持つ。
  ///
  /// Example:
  /// ```dart
  /// TrendsScreenState.initial;
  /// ```
  const TrendsScreenState({required this.period, required this.group});

  /// 初期は過去 30 日・運動グループ。
  static const initial = TrendsScreenState(
    period: TrendsPeriod.days30,
    group: TrendsMetricGroup.exercise,
  );

  /// 選んでいる期間。
  final TrendsPeriod period;

  /// 選んでいる指標グループ。
  final TrendsMetricGroup group;
}
