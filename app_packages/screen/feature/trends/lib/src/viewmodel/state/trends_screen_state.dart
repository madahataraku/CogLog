import 'package:domain_trends/domain_trends.dart';

import '../entity/trends_visible_series.dart';
import 'trends_comparison.dart';
import 'trends_health_permission_ui.dart';

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

/// 推移画面が持つ選択・読込・系列状態。
///
/// Example:
/// ```dart
/// TrendsScreenState.initial;
/// ```
final class TrendsScreenState {
  /// 選択と読込結果を持つ。
  ///
  /// Example:
  /// ```dart
  /// TrendsScreenState.initial;
  /// ```
  const TrendsScreenState({
    required this.period,
    required this.comparison,
    required this.loading,
    required this.bodyReadFailed,
    this.bodyHistoryLimited = false,
    this.bodyPermissionIncomplete = false,
    this.healthPermissionRequested = false,
    required this.healthPermissionUi,
    required this.buckets,
    required this.exerciseSeries,
    required this.bodySeries,
    this.reloadGeneration = 0,
  });

  /// 初期は過去 30 日・カロリー×体重除脂肪・読込中。
  static const initial = TrendsScreenState(
    period: TrendsPeriod.days30,
    comparison: TrendsComparison.caloriesBodyKg,
    loading: true,
    bodyReadFailed: false,
    healthPermissionUi: TrendsHealthPermissionUi.unknown,
    buckets: [],
    exerciseSeries: {},
    bodySeries: {},
  );

  /// 選んでいる期間。
  final TrendsPeriod period;

  /// 選んでいる比較プリセット。
  final TrendsComparison comparison;

  /// 系列の読込中か。
  final bool loading;

  /// 身体指標の読取が失敗したか。
  final bool bodyReadFailed;

  /// Android で履歴許可が無く、直近 30 日より前の身体計測を読めないか。
  final bool bodyHistoryLimited;

  /// Android で身体指標の一部だけが許可されているか。
  final bool bodyPermissionIncomplete;

  /// この画面でヘルス許可リクエストを一度でも実行したか。
  final bool healthPermissionRequested;

  /// ヘルス許可の表示用状態。
  final TrendsHealthPermissionUi healthPermissionUi;

  /// 古い→新しい順のバケット列。
  final List<TrendsBucket> buckets;

  /// 運動 3 指標の系列。
  final Map<TrendsMetricKind, TrendsVisibleSeries> exerciseSeries;

  /// 身体 3 指標の系列。
  final Map<TrendsMetricKind, TrendsVisibleSeries> bodySeries;

  /// 再取得の世代。新しい読込開始のたびに増やす。
  final int reloadGeneration;

  /// 指定したフィールドだけ差し替える。
  ///
  /// Example:
  /// ```dart
  /// TrendsScreenState.initial.copyWith(loading: false);
  /// ```
  TrendsScreenState copyWith({
    TrendsPeriod? period,
    TrendsComparison? comparison,
    bool? loading,
    bool? bodyReadFailed,
    bool? bodyHistoryLimited,
    bool? bodyPermissionIncomplete,
    bool? healthPermissionRequested,
    TrendsHealthPermissionUi? healthPermissionUi,
    List<TrendsBucket>? buckets,
    Map<TrendsMetricKind, TrendsVisibleSeries>? exerciseSeries,
    Map<TrendsMetricKind, TrendsVisibleSeries>? bodySeries,
    int? reloadGeneration,
  }) => TrendsScreenState(
    period: period ?? this.period,
    comparison: comparison ?? this.comparison,
    loading: loading ?? this.loading,
    bodyReadFailed: bodyReadFailed ?? this.bodyReadFailed,
    bodyHistoryLimited: bodyHistoryLimited ?? this.bodyHistoryLimited,
    bodyPermissionIncomplete:
        bodyPermissionIncomplete ?? this.bodyPermissionIncomplete,
    healthPermissionRequested:
        healthPermissionRequested ?? this.healthPermissionRequested,
    healthPermissionUi: healthPermissionUi ?? this.healthPermissionUi,
    buckets: buckets ?? this.buckets,
    exerciseSeries: exerciseSeries ?? this.exerciseSeries,
    bodySeries: bodySeries ?? this.bodySeries,
    reloadGeneration: reloadGeneration ?? this.reloadGeneration,
  );
}
