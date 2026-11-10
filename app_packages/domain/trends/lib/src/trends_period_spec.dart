/// 推移画面で選べる期間の種類。
///
/// 日数と点間隔の対応は [TrendsPeriodSpec] が持つ。
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

/// 期間種類に対応する日数と点間隔。
///
/// [dayCount] は本日を含む表示日数。[spacingDays] はバケットの標準長。
///
/// Example:
/// ```dart
/// TrendsPeriodSpec.of(TrendsPeriodKind.days90).spacingDays;
/// ```
final class TrendsPeriodSpec {
  /// 種類・日数・間隔を持つ仕様を作る。
  ///
  /// Example:
  /// ```dart
  /// const TrendsPeriodSpec(
  ///   kind: TrendsPeriodKind.days30,
  ///   dayCount: 30,
  ///   spacingDays: 1,
  /// );
  /// ```
  const TrendsPeriodSpec({
    required this.kind,
    required this.dayCount,
    required this.spacingDays,
  });

  /// 期間の種類。
  final TrendsPeriodKind kind;

  /// 本日を含む表示日数。
  final int dayCount;

  /// バケットの標準日数（点の間隔）。
  final int spacingDays;

  /// 過去 30 日・1 日ごと。
  static const days30 = TrendsPeriodSpec(
    kind: TrendsPeriodKind.days30,
    dayCount: 30,
    spacingDays: 1,
  );

  /// 過去 90 日・7 日ごと。
  static const days90 = TrendsPeriodSpec(
    kind: TrendsPeriodKind.days90,
    dayCount: 90,
    spacingDays: 7,
  );

  /// 過去 182 日・14 日ごと。
  static const days182 = TrendsPeriodSpec(
    kind: TrendsPeriodKind.days182,
    dayCount: 182,
    spacingDays: 14,
  );

  /// 過去 365 日・28 日ごと。
  static const days365 = TrendsPeriodSpec(
    kind: TrendsPeriodKind.days365,
    dayCount: 365,
    spacingDays: 28,
  );

  /// [kind] に対応する仕様を返す。
  ///
  /// Example:
  /// ```dart
  /// TrendsPeriodSpec.of(TrendsPeriodKind.days182);
  /// ```
  static TrendsPeriodSpec of(TrendsPeriodKind kind) => switch (kind) {
    TrendsPeriodKind.days30 => days30,
    TrendsPeriodKind.days90 => days90,
    TrendsPeriodKind.days182 => days182,
    TrendsPeriodKind.days365 => days365,
  };
}
