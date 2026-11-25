import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

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
///   pendingGemmaMeterGuidance: false,
///   hasNewAchievements: false,
///   showWeeklyGoalGuidance: true,
///   weeklyAchievementDays: null,
///   weekGoalAchievementDayCount: 0,
///   weeklyProgress: 0,
///   weeklyRemaining: 0,
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
  /// 指標・期間表記・アドバイス・誘導・新規有無・週間達成・3 指標の達成を持つ。
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
  ///   pendingGemmaMeterGuidance: false,
  ///   hasNewAchievements: false,
  ///   showWeeklyGoalGuidance: false,
  ///   weeklyAchievementDays: 5,
  ///   weekGoalAchievementDayCount: 2,
  ///   weeklyProgress: 0.4,
  ///   weeklyRemaining: 3,
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
    required this.pendingGemmaMeterGuidance,
    required this.pendingTutorialMain,
    required this.tutorialMainStep,
    required this.pendingTutorialAchievement,
    required this.hasNewAchievements,
    required this.showWeeklyGoalGuidance,
    required this.weeklyAchievementDays,
    required this.weekGoalAchievementDayCount,
    required this.weeklyProgress,
    required this.weeklyRemaining,
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

  /// OS LLM モデル未ダウンロード誘導 (A) を表示予約しているとき true。
  final bool pendingModelDownloadGuidance;

  /// Gemma メーター誘導 (B) を表示予約しているとき true。
  final bool pendingGemmaMeterGuidance;

  /// メインチュートリアルを表示予約しているとき true。
  final bool pendingTutorialMain;

  /// 吹き出し文言切替用のメイン段階。
  final TutorialMainStep? tutorialMainStep;

  /// アチーブメント文脈を表示予約しているとき true。
  final bool pendingTutorialAchievement;

  /// trophy に新規ドットを出すとき true。
  final bool hasNewAchievements;

  /// 週間ゲージの代わりに設定誘導を出すとき true。
  final bool showWeeklyGoalGuidance;

  /// 週間目標達成日数。誘導時は null。
  final int? weeklyAchievementDays;

  /// 今週の目標達成日数。
  final int weekGoalAchievementDayCount;

  /// ゲージ進捗 0〜1。
  final double weeklyProgress;

  /// 残り達成日数。
  final int weeklyRemaining;

  /// 運動時間の達成リング。
  final TopGoalRingEntity duration;

  /// 消費カロリーの達成リング。
  final TopGoalRingEntity calories;

  /// 走行距離の達成リング。
  final TopGoalRingEntity distance;
}
