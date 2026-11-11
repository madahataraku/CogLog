import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';

/// 最終閲覧日時を Repository へ書く。
///
/// Example:
/// ```dart
/// MarkAchievementsViewedUsecaseImpl(achievements: achievements).execute(
///   MarkAchievementsViewedRequest(now: DateTime.utc(2026, 11, 11)),
/// );
/// ```
final class MarkAchievementsViewedUsecaseImpl
    implements MarkAchievementsViewedUsecase {
  /// [achievements] へ書き込む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// MarkAchievementsViewedUsecaseImpl(achievements: achievements);
  /// ```
  const MarkAchievementsViewedUsecaseImpl({required this.achievements});

  /// 獲得・閲覧の永続。
  final AchievementRepository achievements;

  /// [request.now] を UTC で保存する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   MarkAchievementsViewedRequest(now: DateTime.timestamp()),
  /// );
  /// ```
  @override
  Future<void> execute(MarkAchievementsViewedRequest request) =>
      achievements.writeLastViewedAt(request.now.toUtc());
}
