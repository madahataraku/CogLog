import 'package:data_repository_achievement_testing/data_repository_achievement_testing.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:test/test.dart';
import 'package:usecase_load_achievements_impl/usecase_load_achievements_impl.dart';

void main() {
  test('未保存なら初期化し既存獲得は新規にしない', () async {
    final achievements = MemoryAchievementRepository();
    await achievements.mergeUnlocks([
      AchievementUnlock(
        id: 'first_record',
        unlockedAt: DateTime.utc(2026, 11, 1),
      ),
    ]);
    final now = DateTime.utc(2026, 11, 11);

    final hasNew = await LoadAchievementNewIndicatorUsecaseImpl(
      achievements: achievements,
    ).execute(now: now);

    expect(hasNew, isFalse);
    expect(await achievements.readLastViewedAt(), now);
  });

  test('最終閲覧より後の獲得があれば true', () async {
    final achievements = MemoryAchievementRepository();
    await achievements.writeLastViewedAt(DateTime.utc(2026, 11, 10));
    await achievements.mergeUnlocks([
      AchievementUnlock(
        id: 'first_record',
        unlockedAt: DateTime.utc(2026, 11, 11),
      ),
    ]);

    final hasNew = await LoadAchievementNewIndicatorUsecaseImpl(
      achievements: achievements,
    ).execute(now: DateTime.utc(2026, 11, 12));

    expect(hasNew, isTrue);
  });
}
