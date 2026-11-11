import 'package:domain_achievement/domain_achievement.dart';
import 'package:test/test.dart';

void main() {
  final unlock = AchievementUnlock(
    id: 'first_record',
    unlockedAt: DateTime.utc(2026, 11, 11, 12),
  );

  test('最終閲覧が null なら新規にしない', () {
    expect(achievementIsNew(unlock: unlock, lastViewedAt: null), isFalse);
  });

  test('獲得日時が最終閲覧と同値なら新規にしない', () {
    expect(
      achievementIsNew(
        unlock: unlock,
        lastViewedAt: DateTime.utc(2026, 11, 11, 12),
      ),
      isFalse,
    );
  });

  test('獲得日時が最終閲覧より後なら新規', () {
    expect(
      achievementIsNew(
        unlock: unlock,
        lastViewedAt: DateTime.utc(2026, 11, 10),
      ),
      isTrue,
    );
  });
}
