/// 推移の 1 バケット区間。
///
/// 半開区間 `[startInclusive, endExclusive)`。代表日は末尾日（今日側）の 0:00。
///
/// Example:
/// ```dart
/// const TrendsBucket(
///   startInclusive: DateTime(2026, 11, 10),
///   endExclusive: DateTime(2026, 11, 11),
///   representativeDate: DateTime(2026, 11, 10),
/// );
/// ```
final class TrendsBucket {
  /// 両端と代表日を持つバケットを作る。
  ///
  /// Example:
  /// ```dart
  /// TrendsBucket(
  ///   startInclusive: DateTime(2026, 11, 4),
  ///   endExclusive: DateTime(2026, 11, 11),
  ///   representativeDate: DateTime(2026, 11, 10),
  /// );
  /// ```
  const TrendsBucket({
    required this.startInclusive,
    required this.endExclusive,
    required this.representativeDate,
  });

  /// 含む端（現地 0:00）。
  final DateTime startInclusive;

  /// 含まない端（現地 0:00）。
  final DateTime endExclusive;

  /// バケット末尾日の現地 0:00（[endExclusive] の前日）。
  final DateTime representativeDate;

  /// 区間の日数。
  ///
  /// Example:
  /// ```dart
  /// const TrendsBucket(
  ///   startInclusive: DateTime(2026, 11, 4),
  ///   endExclusive: DateTime(2026, 11, 11),
  ///   representativeDate: DateTime(2026, 11, 10),
  /// ).lengthDays;
  /// ```
  int get lengthDays => endExclusive.difference(startInclusive).inDays;

  /// [at] を現地時刻へ直して、この半開区間に入るか。
  ///
  /// Example:
  /// ```dart
  /// const TrendsBucket(
  ///   startInclusive: DateTime(2026, 11, 10),
  ///   endExclusive: DateTime(2026, 11, 11),
  ///   representativeDate: DateTime(2026, 11, 10),
  /// ).contains(DateTime(2026, 11, 10, 12));
  /// ```
  bool contains(DateTime at) {
    final local = at.toLocal();
    return !local.isBefore(startInclusive) && local.isBefore(endExclusive);
  }
}
