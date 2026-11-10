import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';

/// 獲得記録と履歴から一覧行を組み立てる。
///
/// Example:
/// ```dart
/// LoadAchievementsUsecaseImpl(
///   achievements: achievements,
///   histories: histories,
/// ).execute(LoadAchievementsRequest(now: DateTime(2026, 11, 10)));
/// ```
final class LoadAchievementsUsecaseImpl implements LoadAchievementsUsecase {
  /// [achievements] と [histories] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadAchievementsUsecaseImpl(
  ///   achievements: achievements,
  ///   histories: histories,
  /// );
  /// ```
  const LoadAchievementsUsecaseImpl({
    required this.achievements,
    required this.histories,
  });

  /// 獲得記録。
  final AchievementRepository achievements;

  /// 運動履歴。
  final ExerciseHistoryRepository histories;

  /// 失敗時は [LoadAchievementsFailed]、成功時はカタログ順の行を返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(LoadAchievementsRequest(now: DateTime.timestamp()));
  /// ```
  @override
  Future<LoadAchievementsResult> execute(
    LoadAchievementsRequest request,
  ) async {
    try {
      final unlocks = await achievements.readUnlocks();
      final unlockedIds = {for (final unlock in unlocks) unlock.id};
      final all = await histories.list();
      final progress = AchievementEvaluator.evaluate(all, request.now);
      final definitionsById = {
        for (final definition in AchievementCatalog.all)
          definition.id: definition,
      };

      final rows = [
        for (final item in progress)
          AchievementRow(
            id: item.id,
            unlocked: unlockedIds.contains(item.id),
            current: item.current,
            target: item.target,
            progressRatio: item.ratio,
            binaryProgress: definitionsById[item.id]?.binaryProgress ?? false,
          ),
      ];
      return LoadAchievementsSuccess(rows);
    } on Object {
      // 一覧失敗を画面の再試行へ渡すため、例外は failed に畳む。
      return const LoadAchievementsFailed();
    }
  }
}
