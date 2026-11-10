import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

import 'top_goal_ring_entity.dart';

/// トップ画面が表示する文字列、アドバイス吹き出し用の本文とトーン、達成率。
///
/// Example:
/// ```dart
/// TopScreenEntity(
///   metric: PeriodTotalMetric.calories,
///   todayText: '--',
///   weekText: '--',
///   monthText: '--',
///   adviceText: '',
///   adviceTone: AdviceTone.fun,
///   pendingModelDownloadGuidance: false,
///   duration: const TopGoalRingEntity(
///     status: GoalMetricStatus.unset,
///     lap1: 0,
///     lap2: 0,
///     percentText: '',
///     actualText: '',
///     goalText: '',
///   ),
///   calories: const TopGoalRingEntity(
///     status: GoalMetricStatus.unset,
///     lap1: 0,
///     lap2: 0,
///     percentText: '',
///     actualText: '',
///     goalText: '',
///   ),
///   distance: const TopGoalRingEntity(
///     status: GoalMetricStatus.unset,
///     lap1: 0,
///     lap2: 0,
///     percentText: '',
///     actualText: '',
///     goalText: '',
///   ),
/// );
/// ```
final class TopScreenEntity {
  /// 指標・期間表記・アドバイス本文とトーン・誘導予約・3 指標の達成を持つ。
  ///
  /// Example:
  /// ```dart
  /// TopScreenEntity(
  ///   metric: PeriodTotalMetric.calories,
  ///   todayText: '--',
  ///   weekText: '--',
  ///   monthText: '--',
  ///   adviceText: '',
  ///   adviceTone: AdviceTone.fun,
  ///   pendingModelDownloadGuidance: false,
  ///   duration: ring,
  ///   calories: ring,
  ///   distance: ring,
  /// );
  /// ```
  const TopScreenEntity({
    required this.metric,
    required this.todayText,
    required this.weekText,
    required this.monthText,
    required this.adviceText,
    required this.adviceTone,
    required this.pendingModelDownloadGuidance,
    required this.duration,
    required this.calories,
    required this.distance,
  });

  /// 選択中の指標。
  final PeriodTotalMetric metric;

  /// 本日の表記。
  final String todayText;

  /// 今週の表記。
  final String weekText;

  /// 今月の表記。
  final String monthText;

  /// ワンポイントアドバイス。
  final String adviceText;

  /// ワンポイントアドバイスのトーン。
  final AdviceTone adviceTone;

  /// モデル未ダウンロード誘導を表示予約しているとき true。
  final bool pendingModelDownloadGuidance;

  /// 運動時間の達成リング。
  final TopGoalRingEntity duration;

  /// 消費カロリーの達成リング。
  final TopGoalRingEntity calories;

  /// 走行距離の達成リング。
  final TopGoalRingEntity distance;
}
