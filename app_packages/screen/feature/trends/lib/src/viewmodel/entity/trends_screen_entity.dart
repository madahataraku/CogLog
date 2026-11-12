import '../state/trends_comparison.dart';
import '../state/trends_screen_state.dart';
import 'trends_visible_series.dart';

/// 推移画面の表示用選択・ボタン・系列。
///
/// Example:
/// ```dart
/// TrendsScreenEntity(
///   period: TrendsPeriod.days30,
///   comparison: TrendsComparison.caloriesBodyKg,
///   loading: false,
///   showRequestPermissionButton: false,
///   showRequestHistoryButton: false,
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
  ///   comparison: TrendsComparison.caloriesBodyKg,
  ///   loading: true,
  ///   showRequestPermissionButton: false,
  ///   showRequestHistoryButton: false,
  ///   showOpenSettingsButton: false,
  ///   showRetryButton: false,
  ///   visibleSeries: const [],
  ///   bucketCount: 0,
  /// );
  /// ```
  const TrendsScreenEntity({
    required this.period,
    required this.comparison,
    required this.loading,
    required this.showRequestPermissionButton,
    required this.showRequestHistoryButton,
    required this.showOpenSettingsButton,
    required this.showRetryButton,
    required this.visibleSeries,
    required this.bucketCount,
  });

  /// 選んでいる期間。
  final TrendsPeriod period;

  /// 選んでいる比較プリセット。
  final TrendsComparison comparison;

  /// 系列の読込中か。
  final bool loading;

  /// 身体を含む比較で許可リクエストボタンを出すか。
  final bool showRequestPermissionButton;

  /// 身体指標は許可済みだが Android 履歴許可が足りないとき出すか。
  final bool showRequestHistoryButton;

  /// 身体を含む比較で OS 設定ボタンを出すか。
  final bool showOpenSettingsButton;

  /// 系列の読込失敗時に再試行ボタンを出すか。
  final bool showRetryButton;

  /// いま描く系列。
  final List<TrendsVisibleSeries> visibleSeries;

  /// グラフ X スロット数（バケット数）。
  final int bucketCount;
}
