import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';

/// 履歴と獲得 Repository から新規充足を merge する。
///
/// Example:
/// ```dart
/// EvaluateAchievementsUsecaseImpl(
///   achievements: achievements,
///   histories: histories,
/// ).execute(
///   EvaluateAchievementsRequest(
///     now: DateTime(2026, 11, 10),
///     emitNotifications: true,
///   ),
/// );
/// ```
final class EvaluateAchievementsUsecaseImpl
    implements EvaluateAchievementsUsecase {
  /// [achievements] と [histories] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// EvaluateAchievementsUsecaseImpl(
  ///   achievements: achievements,
  ///   histories: histories,
  /// );
  /// ```
  const EvaluateAchievementsUsecaseImpl({
    required this.achievements,
    required this.histories,
  });

  /// 獲得記録。
  final AchievementRepository achievements;

  /// 運動履歴。
  final ExerciseHistoryRepository histories;

  /// 達成済みかつ未所持を merge し、通知対象の差分だけ返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   EvaluateAchievementsRequest(
  ///     now: DateTime.timestamp(),
  ///     emitNotifications: true,
  ///   ),
  /// );
  /// ```
  @override
  Future<EvaluateAchievementsResult> execute(
    EvaluateAchievementsRequest request,
  ) async {
    final existing = await achievements.readUnlocks();
    final existingIds = {for (final unlock in existing) unlock.id};
    final isInitialBackfill = existing.isEmpty;

    final all = await histories.list();
    final progress = AchievementEvaluator.evaluate(all, request.now);
    final newlySatisfied = [
      for (final item in progress)
        if (item.achieved && !existingIds.contains(item.id))
          AchievementUnlock(id: item.id, unlockedAt: request.now.toUtc()),
    ];

    if (newlySatisfied.isNotEmpty) {
      await achievements.mergeUnlocks(newlySatisfied);
    }

    final newlyForToast = (!request.emitNotifications || isInitialBackfill)
        ? const <AchievementUnlock>[]
        : newlySatisfied;

    return EvaluateAchievementsResult(newlyUnlocked: newlyForToast);
  }
}
