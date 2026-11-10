import 'package:domain_trends/domain_trends.dart';

import 'load_trends_health_permission.dart';
import 'load_trends_series.dart';

/// 推移画面用のバケットと運動・身体系列。
///
/// [exerciseSeries] は 3 指標を常に持つ。[bodySeries] も 3 キーを揃え、
/// 未許可や読取失敗では点を空にする。
///
/// Example:
/// ```dart
/// LoadTrendsResult(
///   buckets: const [],
///   exerciseSeries: const {},
///   bodySeries: const {},
///   healthPermission: LoadTrendsHealthPermission.unknown,
///   bodyReadFailed: false,
/// );
/// ```
final class LoadTrendsResult {
  /// バケット・系列・許可・読取失敗フラグを持つ結果を作る。
  ///
  /// Example:
  /// ```dart
  /// const LoadTrendsResult(
  ///   buckets: [],
  ///   exerciseSeries: {},
  ///   bodySeries: {},
  ///   healthPermission: LoadTrendsHealthPermission.denied,
  ///   bodyReadFailed: false,
  /// );
  /// ```
  const LoadTrendsResult({
    required this.buckets,
    required this.exerciseSeries,
    required this.bodySeries,
    required this.healthPermission,
    required this.bodyReadFailed,
    this.bodyHistoryLimited = false,
  });

  /// 古い→新しい順のバケット列。
  final List<TrendsBucket> buckets;

  /// 運動 3 指標の系列。
  final Map<TrendsMetricKind, LoadTrendsSeries> exerciseSeries;

  /// 身体 3 指標の系列。
  final Map<TrendsMetricKind, LoadTrendsSeries> bodySeries;

  /// usecase 境界の許可状態。
  final LoadTrendsHealthPermission healthPermission;

  /// 身体指標の読取が例外で失敗したか。
  final bool bodyReadFailed;

  /// Android で履歴許可が無く、直近 30 日より前を読めないか。
  final bool bodyHistoryLimited;
}
