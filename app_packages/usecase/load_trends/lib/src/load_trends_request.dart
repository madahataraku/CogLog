import 'package:domain_trends/domain_trends.dart';

/// 推移系列を読み込むときの期間とグループ。
///
/// Example:
/// ```dart
/// LoadTrendsRequest(
///   now: DateTime(2026, 11, 10, 15),
///   period: TrendsPeriodKind.days30,
///   groupIsBody: false,
/// );
/// ```
final class LoadTrendsRequest {
  /// [now]・[period]・[groupIsBody] を持つ要求を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadTrendsRequest(
  ///   now: DateTime(2026, 11, 10),
  ///   period: TrendsPeriodKind.days90,
  ///   groupIsBody: true,
  /// );
  /// ```
  const LoadTrendsRequest({
    required this.now,
    required this.period,
    required this.groupIsBody,
  });

  /// バケット境界に使う現地時刻。
  final DateTime now;

  /// 表示期間。
  final TrendsPeriodKind period;

  /// 身体グループを表示中か。読取自体はグループに依らない。
  final bool groupIsBody;
}
