import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';

/// 最終閲覧の初期化と新規有無の判定。
///
/// Example:
/// ```dart
/// LoadAchievementNewIndicatorUsecaseImpl(achievements: achievements).execute(
///   now: DateTime.utc(2026, 11, 11),
/// );
/// ```
final class LoadAchievementNewIndicatorUsecaseImpl
    implements LoadAchievementNewIndicatorUsecase {
  /// [achievements] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadAchievementNewIndicatorUsecaseImpl(achievements: achievements);
  /// ```
  const LoadAchievementNewIndicatorUsecaseImpl({required this.achievements});

  /// 獲得・閲覧の永続。
  final AchievementRepository achievements;

  /// 未保存なら初期化し、新規が 1 件以上なら true。失敗時は false。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(now: DateTime.timestamp());
  /// ```
  @override
  Future<bool> execute({required DateTime now}) async {
    try {
      var last = await achievements.readLastViewedAt();
      if (last == null) {
        final stamped = now.toUtc();
        await achievements.writeLastViewedAt(stamped);
        last = stamped;
      }
      final unlocks = await achievements.readUnlocks();
      return unlocks.any(
        (unlock) => achievementIsNew(unlock: unlock, lastViewedAt: last),
      );
    } on Object {
      // ホーム本体を落とさない。
      return false;
    }
  }
}
