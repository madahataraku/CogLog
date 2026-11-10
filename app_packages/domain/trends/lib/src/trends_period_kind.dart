/// 推移画面で選べる期間の種類。
///
/// 日数と点間隔の対応は期間仕様が持つ。
///
/// Example:
/// ```dart
/// TrendsPeriodKind.days30;
/// ```
enum TrendsPeriodKind {
  /// 過去 30 日（1 日ごと）。
  days30,

  /// 過去 90 日（7 日ごと）。
  days90,

  /// 過去 182 日（14 日ごと）。
  days182,

  /// 過去 365 日（28 日ごと）。
  days365,
}
