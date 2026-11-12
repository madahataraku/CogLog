import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'update_exercise_history_outcome.dart';

/// 運動履歴更新 Usecase の結果。
///
/// Example:
/// ```dart
/// const UpdateExerciseHistoryResult(
///   outcome: UpdateExerciseHistoryOutcome.success,
/// );
/// ```
final class UpdateExerciseHistoryResult {
  /// [outcome] を中心に結果を作る。
  ///
  /// Example:
  /// ```dart
  /// const UpdateExerciseHistoryResult(
  ///   outcome: UpdateExerciseHistoryOutcome.success,
  /// );
  /// ```
  const UpdateExerciseHistoryResult({
    required this.outcome,
    this.history,
    this.recordedLocalDayChanged = false,
    this.goalAutoUpdated = false,
    this.newlyUnlockedAchievements = const [],
  });

  /// 成否区分。
  final UpdateExerciseHistoryOutcome outcome;

  /// 成功時の永続化結果。
  final ExerciseHistory? history;

  /// 記録日時の現地暦日が編集前後で変わったか。
  final bool recordedLocalDayChanged;

  /// 更新後の目標自動更新が適用されたか。
  final bool goalAutoUpdated;

  /// 更新直後の評価でトースト対象となった新規獲得。評価失敗時は空。
  final List<AchievementUnlock> newlyUnlockedAchievements;
}
