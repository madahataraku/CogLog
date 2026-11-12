import 'package:domain_trends/domain_trends.dart';

/// 推移系列を読み込むときの期間。
///
/// Example:
/// ```dart
/// LoadTrendsRequest(
///   now: DateTime(2026, 11, 10, 15),
///   period: TrendsPeriodKind.days30,
/// );
/// ```
final class LoadTrendsRequest {
  /// [now] と [period] を持つ要求を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadTrendsRequest(
  ///   now: DateTime(2026, 11, 10),
  ///   period: TrendsPeriodKind.days90,
  /// );
  /// ```
  const LoadTrendsRequest({required this.now, required this.period});

  /// バケット境界に使う現地時刻。
  final DateTime now;

  /// 表示期間。
  final TrendsPeriodKind period;
}
