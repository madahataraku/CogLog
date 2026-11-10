import '../state/trends_screen_state.dart';

/// 推移画面の表示用選択状態。
///
/// Example:
/// ```dart
/// TrendsScreenEntity(
///   period: TrendsPeriod.days30,
///   group: TrendsMetricGroup.exercise,
/// );
/// ```
final class TrendsScreenEntity {
  /// [period] と [group] を持つ。
  ///
  /// Example:
  /// ```dart
  /// TrendsScreenEntity(
  ///   period: TrendsPeriod.days30,
  ///   group: TrendsMetricGroup.exercise,
  /// );
  /// ```
  const TrendsScreenEntity({required this.period, required this.group});

  /// 選んでいる期間。
  final TrendsPeriod period;

  /// 選んでいる指標グループ。
  final TrendsMetricGroup group;
}
