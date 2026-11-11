import 'package:data_repository_achievement_impl/data_repository_achievement_impl.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(SharedPreferences.resetStatic);

  test('未保存は空リスト', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesAchievementRepository(
      await SharedPreferences.getInstance(),
    );

    expect(await repository.readUnlocks(), isEmpty);
  });

  test('書いて読める', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final repository = SharedPreferencesAchievementRepository(preferences);
    final unlockedAt = DateTime.utc(2026, 11, 10, 12);

    await repository.mergeUnlocks([
      AchievementUnlock(id: 'first_record', unlockedAt: unlockedAt),
    ]);

    final unlocks = await repository.readUnlocks();
    expect(unlocks, hasLength(1));
    expect(unlocks.single.id, 'first_record');
    expect(unlocks.single.unlockedAt, unlockedAt);
  });

  test('既存 id の unlockedAt は上書きしない', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesAchievementRepository(
      await SharedPreferences.getInstance(),
    );
    final first = DateTime.utc(2026, 11, 1);
    final second = DateTime.utc(2026, 11, 10);

    await repository.mergeUnlocks([
      AchievementUnlock(id: 'first_record', unlockedAt: first),
    ]);
    await repository.mergeUnlocks([
      AchievementUnlock(id: 'first_record', unlockedAt: second),
      AchievementUnlock(id: 'streak_3', unlockedAt: second),
    ]);

    final unlocks = await repository.readUnlocks();
    final byId = {for (final unlock in unlocks) unlock.id: unlock};
    expect(byId['first_record']!.unlockedAt, first);
    expect(byId['streak_3']!.unlockedAt, second);
  });

  test('破損 JSON は空リスト', () async {
    SharedPreferences.setMockInitialValues({
      'achievement_unlocks': '{not-json',
    });
    final repository = SharedPreferencesAchievementRepository(
      await SharedPreferences.getInstance(),
    );

    expect(await repository.readUnlocks(), isEmpty);
  });

  test('配列でない JSON は空リスト', () async {
    SharedPreferences.setMockInitialValues({
      'achievement_unlocks': '{"id":"first_record"}',
    });
    final repository = SharedPreferencesAchievementRepository(
      await SharedPreferences.getInstance(),
    );

    expect(await repository.readUnlocks(), isEmpty);
  });

  test('未知 id は読み捨てる', () async {
    SharedPreferences.setMockInitialValues({
      'achievement_unlocks':
          '[{"id":"unknown_badge","unlockedAt":"2026-11-10T00:00:00.000Z"},'
          '{"id":"first_record","unlockedAt":"2026-11-10T00:00:00.000Z"}]',
    });
    final repository = SharedPreferencesAchievementRepository(
      await SharedPreferences.getInstance(),
    );

    final unlocks = await repository.readUnlocks();
    expect(unlocks, hasLength(1));
    expect(unlocks.single.id, 'first_record');
  });

  test('未知 id の merge は保存しない', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesAchievementRepository(
      await SharedPreferences.getInstance(),
    );

    await repository.mergeUnlocks([
      AchievementUnlock(
        id: 'unknown_badge',
        unlockedAt: DateTime.utc(2026, 11, 10),
      ),
    ]);

    expect(await repository.readUnlocks(), isEmpty);
  });
}
