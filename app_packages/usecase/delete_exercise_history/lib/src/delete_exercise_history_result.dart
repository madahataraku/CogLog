import 'package:domain_achievement/domain_achievement.dart';

import 'delete_exercise_history_outcome.dart';

/// 運動履歴削除 Usecase の結果。
///
/// Example:
/// ```dart
/// const DeleteExerciseHistoryResult(
///   outcome: DeleteExerciseHistoryOutcome.success,
/// );
/// ```
final class DeleteExerciseHistoryResult {
  /// [outcome] を中心に結果を作る。
  ///
  /// Example:
  /// ```dart
  /// const DeleteExerciseHistoryResult(
  ///   outcome: DeleteExerciseHistoryOutcome.success,
  /// );
  /// ```
  const DeleteExerciseHistoryResult({
    required this.outcome,
    this.goalAutoUpdated = false,
    this.newlyUnlockedAchievements = const [],
  });

  /// 成否区分。
  final DeleteExerciseHistoryOutcome outcome;

  /// 削除後の目標自動更新が適用されたか。
  final bool goalAutoUpdated;

  /// 削除直後の評価でトースト対象となった新規獲得。評価失敗時は空。
  final List<AchievementUnlock> newlyUnlockedAchievements;
}
