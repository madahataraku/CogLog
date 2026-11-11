import 'package:data_repository_achievement_testing/data_repository_achievement_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_load_achievements_impl/usecase_load_achievements_impl.dart';

void main() {
  test('最終閲覧日時を UTC で書く', () async {
    final achievements = MemoryAchievementRepository();
    final now = DateTime(2026, 11, 11, 12);

    await MarkAchievementsViewedUsecaseImpl(achievements: achievements)
        .execute(MarkAchievementsViewedRequest(now: now));

    expect(await achievements.readLastViewedAt(), now.toUtc());
  });
}
