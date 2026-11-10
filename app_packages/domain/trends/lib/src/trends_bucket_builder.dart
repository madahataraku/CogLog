import 'trends_bucket.dart';
import 'trends_period_spec.dart';

/// 期間仕様から古い→新しい順のバケット列を作る。
///
/// 今日を終点に [TrendsPeriodSpec.spacingDays] ずつ過去へ切り、端数は最古側の短いバケットにする。
///
/// Example:
/// ```dart
/// TrendsBucketBuilder.build(
///   nowLocal: DateTime(2026, 11, 10),
///   spec: TrendsPeriodSpec.days30,
/// );
/// ```
final class TrendsBucketBuilder {
  /// 静的 API だけを公開する。
  ///
  /// Example:
  /// ```dart
  /// TrendsBucketBuilder.build(
  ///   nowLocal: DateTime(2026, 11, 10),
  ///   spec: TrendsPeriodSpec.days30,
  /// );
  /// ```
  const TrendsBucketBuilder._();

  /// [nowLocal] の日付を終点に、[spec] のバケット列を返す。
  ///
  /// Example:
  /// ```dart
  /// final buckets = TrendsBucketBuilder.build(
  ///   nowLocal: DateTime(2026, 11, 10, 15),
  ///   spec: TrendsPeriodSpec.days90,
  /// );
  /// ```
  static List<TrendsBucket> build({
    required DateTime nowLocal,
    required TrendsPeriodSpec spec,
  }) {
    final local = nowLocal.toLocal();
    final todayStart = DateTime(local.year, local.month, local.day);
    final rangeStart = _addCalendarDays(todayStart, -(spec.dayCount - 1));
    final endExclusive = _addCalendarDays(todayStart, 1);

    var cursorEnd = endExclusive;
    final buckets = <TrendsBucket>[];
    while (cursorEnd.isAfter(rangeStart)) {
      final candidateStart = _addCalendarDays(cursorEnd, -spec.spacingDays);
      final start = candidateStart.isBefore(rangeStart)
          ? rangeStart
          : candidateStart;
      final representativeDate = _addCalendarDays(cursorEnd, -1);
      buckets.add(
        TrendsBucket(
          startInclusive: start,
          endExclusive: cursorEnd,
          representativeDate: representativeDate,
        ),
      );
      cursorEnd = start;
    }
    return buckets.reversed.toList();
  }

  /// 暦日ベースで [days] 日ずらす（DST で 23/25 時間日にずれない）。
  static DateTime _addCalendarDays(DateTime dayStart, int days) {
    return DateTime(dayStart.year, dayStart.month, dayStart.day + days);
  }
}
