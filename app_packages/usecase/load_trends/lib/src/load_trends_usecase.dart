import 'package:riverpod/riverpod.dart';

import 'load_trends_request.dart';
import 'load_trends_result.dart';

/// 推移グラフの系列を読み込む。
///
/// Example:
/// ```dart
/// usecase.execute(
///   LoadTrendsRequest(
///     now: DateTime(2026, 11, 10),
///     period: TrendsPeriodKind.days30,
///     groupIsBody: false,
///   ),
/// );
/// ```
abstract interface class LoadTrendsUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<LoadTrendsUsecase>(
    (ref) => throw UnimplementedError('LoadTrendsUsecase.provider'),
  );

  /// [request] の期間で運動・身体系列を集約する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   LoadTrendsRequest(
  ///     now: DateTime(2026, 11, 10),
  ///     period: TrendsPeriodKind.days30,
  ///     groupIsBody: false,
  ///   ),
  /// );
  /// ```
  Future<LoadTrendsResult> execute(LoadTrendsRequest request);
}
