import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:test/test.dart';

void main() {
  test('ゆっくりは 1.05 倍で秒を切り上げる', () {
    final updated = DailyGoalAutoUpdate.apply(
      const DailyGoal(duration: Duration(seconds: 100)),
      DailyGoalAutoUpdateLevel.slow,
    );
    expect(updated.duration, const Duration(seconds: 105));
  });

  test('ふつう・挑戦的の倍率', () {
    expect(
      DailyGoalAutoUpdate.apply(
        const DailyGoal(caloriesKcal: 100),
        DailyGoalAutoUpdateLevel.normal,
      ).caloriesKcal,
      110,
    );
    expect(
      DailyGoalAutoUpdate.apply(
        const DailyGoal(distanceKm: 1),
        DailyGoalAutoUpdateLevel.challenging,
      ).distanceKm,
      1.25,
    );
  });

  test('ふつうで 3600 秒は浮動小数誤差なく 3960 秒になる', () {
    final updated = DailyGoalAutoUpdate.apply(
      const DailyGoal(duration: Duration(seconds: 3600)),
      DailyGoalAutoUpdateLevel.normal,
    );
    expect(updated.duration, const Duration(seconds: 3960));
  });

  test('未設定と 0 は変えない', () {
    final updated = DailyGoalAutoUpdate.apply(
      const DailyGoal(caloriesKcal: 0),
      DailyGoalAutoUpdateLevel.challenging,
    );
    expect(updated.caloriesKcal, 0);
    expect(updated.duration, isNull);
    expect(updated.distanceKm, isNull);
  });

  test('sameAs は未設定と 0 を区別する', () {
    expect(DailyGoal.unset.sameAs(DailyGoal.unset), isTrue);
    expect(
      const DailyGoal(caloriesKcal: 0).sameAs(const DailyGoal(caloriesKcal: 0)),
      isTrue,
    );
    expect(DailyGoal.unset.sameAs(const DailyGoal(caloriesKcal: 0)), isFalse);
  });
}
