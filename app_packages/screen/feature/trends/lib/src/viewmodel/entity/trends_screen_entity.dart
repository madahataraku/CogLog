import '../state/trends_metric_set.dart';
import '../state/trends_screen_state.dart';
import 'trends_visible_series.dart';

/// 推移画面の表示用選択・ボタン・系列。
///
/// Example:
/// ```dart
/// TrendsScreenEntity(
///   period: TrendsPeriod.days30,
///   group: TrendsMetricGroup.exercise,
///   metricSet: TrendsMetricSet.exerciseCalories,
///   loading: false,
///   showRequestPermissionButton: false,
///   showOpenSettingsButton: false,
///   showRetryButton: false,
///   visibleSeries: const [],
///   bucketCount: 0,
/// );
/// ```
final class TrendsScreenEntity {
  /// 表示に必要な選択とフラグ・系列を持つ。
  ///
  /// Example:
  /// ```dart
  /// TrendsScreenEntity(
  ///   period: TrendsPeriod.days30,
  ///   group: TrendsMetricGroup.exercise,
  ///   metricSet: TrendsMetricSet.exerciseCalories,
  ///   loading: true,
  ///   showRequestPermissionButton: false,
  ///   showOpenSettingsButton: false,
  ///   showRetryButton: false,
  ///   visibleSeries: const [],
  ///   bucketCount: 0,
  /// );
  /// ```
  const TrendsScreenEntity({
    required this.period,
    required this.group,
    required this.metricSet,
    required this.loading,
    required this.showRequestPermissionButton,
    required this.showOpenSettingsButton,
    required this.showRetryButton,
    required this.visibleSeries,
    required this.bucketCount,
  });

  /// 選んでいる期間。
  final TrendsPeriod period;

  /// 選んでいる指標グループ。
  final TrendsMetricGroup group;

  /// グループ内の指標組。
  final TrendsMetricSet metricSet;

  /// 系列の読込中か。
  final bool loading;

  /// 身体グループで許可リクエストボタンを出すか。
  final bool showRequestPermissionButton;

  /// 身体グループで OS 設定ボタンを出すか。
  final bool showOpenSettingsButton;

  /// 身体グループで再試行ボタンを出すか。
  final bool showRetryButton;

  /// いま描く 1〜2 本の系列。
  final List<TrendsVisibleSeries> visibleSeries;

  /// グラフ X スロット数（バケット数）。
  final int bucketCount;
}
