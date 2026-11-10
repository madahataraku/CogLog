import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';

import 'save_meter_capture_outcome.dart';

/// 保存 Usecase の結果。
///
/// Example:
/// ```dart
/// const SaveMeterCaptureResult(outcome: SaveMeterCaptureOutcome.success);
/// ```
final class SaveMeterCaptureResult {
  /// [outcome] を中心に結果を作る。
  ///
  /// Example:
  /// ```dart
  /// const SaveMeterCaptureResult(outcome: SaveMeterCaptureOutcome.success);
  /// ```
  const SaveMeterCaptureResult({
    required this.outcome,
    this.history,
    this.healthWriteSucceeded = false,
    this.goalAutoUpdated = false,
    this.newlyUnlockedAchievements = const [],
  });

  /// 成否区分。
  final SaveMeterCaptureOutcome outcome;

  /// 成功時の永続化結果。
  final ExerciseHistory? history;

  /// ヘルス書き込みが成功したか。失敗しても [outcome] は success になりうる。
  final bool healthWriteSucceeded;

  /// 保存後の目標自動更新が適用されたか。
  final bool goalAutoUpdated;

  /// 保存直後の評価でトースト対象となった新規獲得。評価失敗時は空。
  final List<AchievementUnlock> newlyUnlockedAchievements;
}
