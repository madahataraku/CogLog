import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'advice_template.dart';
import 'conditional_advice_catalog.dart';
import 'conditional_advice_metric.dart';

/// ワンポイントアドバイス生成の依頼。
///
/// [fallbackTemplates] は LLM 不可・失敗時用で 3 件以上あること。
/// [metricLabels] は距離・カロリー・時間の 3 キーを必ず含める（assert で検証）。
///
/// Example:
/// ```dart
/// GenerateTopAdviceRequest(
///   histories: const [],
///   locale: 'ja',
///   now: DateTime(2026, 11, 5),
///   goal: DailyGoal.unset,
///   consecutiveExerciseDays: 0,
///   consecutiveGoalAchievementDays: 0,
///   daysSincePreviousExerciseDay: null,
///   noExercise: AdviceTemplate(
///     text: '今日はまだ運動していません',
///     tone: AdviceTone.realized,
///   ),
///   conditionalCatalog: ConditionalAdviceCatalog(
///     welcomeBack: const [
///       AdviceTemplate(text: 'おかえり', tone: AdviceTone.fun),
///     ],
///   ),
///   metricLabels: {
///     ConditionalAdviceMetric.distance: '距離',
///     ConditionalAdviceMetric.calories: 'カロリー',
///     ConditionalAdviceMetric.duration: '時間',
///   },
///   fallbackTemplates: const [
///     AdviceTemplate(text: 'a', tone: AdviceTone.fun),
///     AdviceTemplate(text: 'b', tone: AdviceTone.happy),
///     AdviceTemplate(text: 'c', tone: AdviceTone.fun),
///   ],
/// );
/// ```
final class GenerateTopAdviceRequest {
  /// 本日履歴・言語・目標・連続日数・未運動定型・条件付き／フォールバック定型を持つ。
  ///
  /// [metricLabels] には [ConditionalAdviceMetric] の 3 値すべてが必要。
  ///
  /// Example:
  /// ```dart
  /// GenerateTopAdviceRequest(
  ///   histories: const [],
  ///   locale: 'ja',
  ///   now: DateTime(2026, 11, 5),
  ///   goal: DailyGoal.unset,
  ///   consecutiveExerciseDays: 0,
  ///   consecutiveGoalAchievementDays: 0,
  ///   daysSincePreviousExerciseDay: null,
  ///   noExercise: AdviceTemplate(
  ///     text: '今日はまだ運動していません',
  ///     tone: AdviceTone.realized,
  ///   ),
  ///   conditionalCatalog: ConditionalAdviceCatalog(),
  ///   metricLabels: {
  ///     ConditionalAdviceMetric.distance: '距離',
  ///     ConditionalAdviceMetric.calories: 'カロリー',
  ///     ConditionalAdviceMetric.duration: '時間',
  ///   },
  ///   fallbackTemplates: const [
  ///     AdviceTemplate(text: 'a', tone: AdviceTone.fun),
  ///     AdviceTemplate(text: 'b', tone: AdviceTone.happy),
  ///     AdviceTemplate(text: 'c', tone: AdviceTone.fun),
  ///   ],
  /// );
  /// ```
  GenerateTopAdviceRequest({
    required this.histories,
    required this.locale,
    required this.now,
    required this.goal,
    required this.consecutiveExerciseDays,
    required this.consecutiveGoalAchievementDays,
    required this.daysSincePreviousExerciseDay,
    required this.noExercise,
    required this.conditionalCatalog,
    required this.metricLabels,
    required this.fallbackTemplates,
  }) : assert(
         metricLabels.length == ConditionalAdviceMetric.values.length &&
             ConditionalAdviceMetric.values.every(metricLabels.containsKey),
         'metricLabels には ConditionalAdviceMetric の 3 キーが必要',
       );

  /// 本日の運動履歴。空なら未運動定型を使う。
  final List<ExerciseHistory> histories;

  /// 言語コード（例: ja / en）。
  final String locale;

  /// 集計・目標達成判定の基準時刻（画面と Load と揃える）。
  final DateTime now;

  /// 一日あたり目標。未設定の指標はプロンプトに含めない。
  final DailyGoal goal;

  /// 本日を起点とした連続運動日数。
  final int consecutiveExerciseDays;

  /// 本日を含めた連続目標達成日数（条件付き定型の判定用）。
  final int consecutiveGoalAchievementDays;

  /// 直前運動日から本日までの暦日差。直前が無ければ null。
  final int? daysSincePreviousExerciseDay;

  /// 履歴 0 件のときに返す定型（本文＋トーン）。
  final AdviceTemplate noExercise;

  /// 条件付きフォールバック用の kind 別定型。
  final ConditionalAdviceCatalog conditionalCatalog;

  /// `{metric}` 置換用ラベル。[ConditionalAdviceMetric] の 3 キー必須（assert）。
  final Map<ConditionalAdviceMetric, String> metricLabels;

  /// LLM 不可・失敗時に選ぶ定型（3 件以上）。条件非該当時の既存乱数用。
  final List<AdviceTemplate> fallbackTemplates;
}
