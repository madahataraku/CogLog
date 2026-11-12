import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

/// 本日履歴の件数と合計を要約した既定プロンプト。
///
/// Example:
/// ```dart
/// const DefaultTopAdvicePromptBuilder();
/// ```
final class DefaultTopAdvicePromptBuilder implements TopAdvicePromptBuilder {
  /// 差し替え可能な既定実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const DefaultTopAdvicePromptBuilder();
  /// ```
  const DefaultTopAdvicePromptBuilder();

  /// 言語・本日の合計・設定済み目標・連続日数を要約し、声と優先の指示のうえ LLM に
  /// `TONE=` / `ADVICE=` の 2 行で返すよう指示したプロンプト文字列を返す。
  ///
  /// Example:
  /// ```dart
  /// const DefaultTopAdvicePromptBuilder().build(
  ///   histories: const [],
  ///   locale: 'ja',
  ///   goal: DailyGoal.unset,
  ///   consecutiveExerciseDays: 0,
  /// );
  /// ```
  @override
  String build({
    required List<ExerciseHistory> histories,
    required String locale,
    required DailyGoal goal,
    required int consecutiveExerciseDays,
  }) {
    var distanceKm = 0.0;
    var caloriesKcal = 0.0;
    var duration = Duration.zero;
    for (final history in histories) {
      distanceKm += history.distanceKm;
      caloriesKcal += history.caloriesKcal;
      duration += history.duration;
    }
    final goalParts = <String>[];
    final durationGoal = goal.duration;
    if (durationGoal != null) {
      goalParts.add('goalDurationMinutes=${durationGoal.inMinutes}');
    }
    final caloriesGoal = goal.caloriesKcal;
    if (caloriesGoal != null) {
      goalParts.add('goalCaloriesKcal=${caloriesGoal.toStringAsFixed(1)}');
    }
    final distanceGoal = goal.distanceKm;
    if (distanceGoal != null) {
      goalParts.add('goalDistanceKm=${distanceGoal.toStringAsFixed(1)}');
    }
    final goalSummary = goalParts.isEmpty ? 'goal=unset' : goalParts.join('; ');
    return 'locale=$locale; '
        'count=${histories.length}; '
        'distanceKm=${distanceKm.toStringAsFixed(1)}; '
        'caloriesKcal=${caloriesKcal.toStringAsFixed(1)}; '
        'durationMinutes=${duration.inMinutes}; '
        '$goalSummary; '
        'consecutiveExerciseDays=$consecutiveExerciseDays. '
        'Speak as a calm guide. '
        'Avoid doctor-like tone, condescension, and hype. '
        'When locale=ja, write ADVICE in polite です・ます Japanese; '
        'for other locales, use calm polite wording in that language. '
        'Priority when advising: (1) relation to any set goals, '
        '(2) consecutive exercise-day streak, '
        '(3) gentle continuity at one\'s own pace, '
        '(4) brief paraphrase of today\'s totals. '
        'If behind a set goal, state the gap factually only; '
        'do not lecture or add extra encouragement. '
        'Weight-loss mentions are allowed only occasionally and modestly. '
        'Choose TONE: happy when a set goal is met, or when the streak is '
        'greater than 0 and the user is not largely behind set goals; '
        'fun when the user has exercised and progress is ordinary; '
        'confused when largely behind set goals (situation clear, not blame); '
        'realized when a clear next step can be stated. '
        'Reply with exactly two lines:\n'
        'TONE=<one of: fun, confused, happy, realized>\n'
        'ADVICE=<short one-point exercise advice in the language of locale=$locale, '
        'aim for at most about 150 characters>\n'
        'Use only those four TONE values. Do not add other lines or markdown.';
  }
}
