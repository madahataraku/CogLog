import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';

/// ワンポイントアドバイス用のプロンプトを組み立てる。
///
/// 差し替え可能。Foundation Models 接続後も同一口から差し替える。
///
/// Example:
/// ```dart
/// builder.build(
///   histories: const [],
///   locale: 'ja',
///   goal: DailyGoal.unset,
///   consecutiveExerciseDays: 0,
/// );
/// ```
abstract interface class TopAdvicePromptBuilder {
  /// [histories]・[locale]・[goal]・[consecutiveExerciseDays] からプロンプトを返す。
  ///
  /// Example:
  /// ```dart
  /// builder.build(
  ///   histories: histories,
  ///   locale: 'ja',
  ///   goal: goal,
  ///   consecutiveExerciseDays: 3,
  /// );
  /// ```
  String build({
    required List<ExerciseHistory> histories,
    required String locale,
    required DailyGoal goal,
    required int consecutiveExerciseDays,
  });
}
