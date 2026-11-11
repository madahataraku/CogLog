import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:usecase_evaluate_achievements/usecase_evaluate_achievements.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';

/// 遡及評価のあと、獲得記録と履歴から一覧行を組み立てる。
///
/// Example:
/// ```dart
/// LoadAchievementsUsecaseImpl(
///   achievements: achievements,
///   histories: histories,
///   evaluate: evaluate,
/// ).execute(LoadAchievementsRequest(now: DateTime(2026, 11, 10)));
/// ```
final class LoadAchievementsUsecaseImpl implements LoadAchievementsUsecase {
  /// [achievements]・[histories]・[evaluate] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadAchievementsUsecaseImpl(
  ///   achievements: achievements,
  ///   histories: histories,
  ///   evaluate: evaluate,
  /// );
  /// ```
  const LoadAchievementsUsecaseImpl({
    required this.achievements,
    required this.histories,
    required this.evaluate,
  });

  /// 獲得記録。
  final AchievementRepository achievements;

  /// 運動履歴。
  final ExerciseHistoryRepository histories;

  /// 一覧表示前の遡及評価（トーストなし）。
  final EvaluateAchievementsUsecase evaluate;

  /// 失敗時は [LoadAchievementsFailed]、成功時はカタログ順の行を返す。
  ///
  /// 表示前に [evaluate] を `emitNotifications: false` で呼び、過去履歴の
  /// 充足分を獲得済みへ反映する。
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
      await evaluate.execute(
        EvaluateAchievementsRequest(now: request.now, emitNotifications: false),
      );

      final unlocks = await achievements.readUnlocks();
      final unlockedIds = {for (final unlock in unlocks) unlock.id};
      final unlockById = {for (final unlock in unlocks) unlock.id: unlock};
      final all = await histories.list();
      final progress = AchievementEvaluator.evaluate(all, request.now);

      DateTime? lastViewedAt;
      try {
        lastViewedAt = await achievements.readLastViewedAt();
      } on Object {
        // 閲覧日時が読めなくても一覧は出す。新規は付けない。
        lastViewedAt = null;
      }

      final rows = [
        for (final item in progress)
          AchievementRow(
            id: item.id,
            unlocked: unlockedIds.contains(item.id),
            current: item.current,
            target: item.target,
            progressRatio: item.ratio,
            binaryProgress: item.binaryProgress,
            isNew:
                unlockedIds.contains(item.id) &&
                unlockById[item.id] != null &&
                achievementIsNew(
                  unlock: unlockById[item.id]!,
                  lastViewedAt: lastViewedAt,
                ),
          ),
      ];
      return LoadAchievementsSuccess(rows);
    } on Object {
      // 一覧失敗を画面の再試行へ渡すため、例外は failed に畳む。
      return const LoadAchievementsFailed();
    }
  }
}
