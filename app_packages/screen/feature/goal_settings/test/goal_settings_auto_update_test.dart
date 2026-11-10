import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';
import 'package:usecase_save_daily_goal_impl/usecase_save_daily_goal_impl.dart';

void main() {
  late MemoryDailyGoalRepository goals;
  final enabledOn = DateTime(2026, 10, 30);
  final epoch = DateTime(2026, 11, 1);
  final applied = DateTime(2026, 11, 2);
  final now = DateTime(2026, 11, 5, 23, 59);
  const goal = DailyGoal(caloriesKcal: 100, distanceKm: 5);

  setUp(() async {
    goals = MemoryDailyGoalRepository();
    await goals.write(goal);
    await goals.writeAutoUpdateSettings(
      DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.normal,
        enabledOnLocalDate: enabledOn,
        streakEpochLocalDate: epoch,
        lastAppliedLocalDate: applied,
      ),
    );
  });

  Future<SaveDailyGoalResult> save({
    DailyGoal nextGoal = goal,
    bool enabled = true,
    DailyGoalAutoUpdateLevel level = DailyGoalAutoUpdateLevel.normal,
    DateTime? at,
  }) => SaveDailyGoalUsecaseImpl(goals: goals).execute(
    SaveDailyGoalRequest(
      goal: nextGoal,
      autoUpdateEnabled: enabled,
      autoUpdateLevel: level,
      now: at ?? now,
    ),
  );

  test('同じ目標とレベルのみの変更では連続達成の日付を保つ', () async {
    final result = await save(level: DailyGoalAutoUpdateLevel.challenging);
    expect(result.autoUpdate.enabledOnLocalDate, enabledOn);
    expect(result.autoUpdate.streakEpochLocalDate, epoch);
    expect(result.autoUpdate.lastAppliedLocalDate, applied);
    final stored = await goals.readAutoUpdateSettings();
    expect(stored.level, DailyGoalAutoUpdateLevel.challenging);
    expect(stored.streakEpochLocalDate, epoch);
  });

  test('無効化では全日付を消し目標と選択レベルを保つ', () async {
    final result = await save(
      enabled: false,
      level: DailyGoalAutoUpdateLevel.slow,
    );
    expect(result.autoUpdate.enabled, isFalse);
    final stored = await goals.readAutoUpdateSettings();
    expect(stored.enabled, isFalse);
    expect(stored.enabledOnLocalDate, isNull);
    expect(stored.streakEpochLocalDate, isNull);
    expect(stored.lastAppliedLocalDate, isNull);
    expect(stored.level, DailyGoalAutoUpdateLevel.slow);
    expect((await goals.read()).sameAs(goal), isTrue);
  });

  test('翌日に再有効化すると過去の達成を数えない', () async {
    await save(enabled: false);
    final result = await save(at: DateTime(2026, 11, 6, 0, 1));
    expect(result.autoUpdate.enabled, isTrue);
    expect(result.autoUpdate.countFromLocalDate, DateTime(2026, 11, 6));
    expect(result.autoUpdate.lastAppliedLocalDate, isNull);
  });

  for (final next in [
    const DailyGoal(caloriesKcal: 101, distanceKm: 5),
    const DailyGoal(caloriesKcal: 100, distanceKm: 6),
    const DailyGoal(
      caloriesKcal: 100,
      distanceKm: 5,
      duration: Duration(seconds: 1),
    ),
    const DailyGoal(caloriesKcal: 100, distanceKm: 0),
    const DailyGoal(caloriesKcal: 100),
  ]) {
    test(
      '目標 ${next.duration}/${next.caloriesKcal}/${next.distanceKm} の変更で起算を戻す',
      () async {
        final result = await save(nextGoal: next);
        expect(result.autoUpdate.streakEpochLocalDate, DateTime(2026, 11, 5));
        expect(result.autoUpdate.enabledOnLocalDate, enabledOn);
        expect(result.autoUpdate.lastAppliedLocalDate, applied);
        expect((await goals.read()).sameAs(next), isTrue);
      },
    );
  }

  test('記録が空なら正の目標があっても連続達成は 0', () {
    expect(ConsecutiveGoalAchievementDays.of([], goal, now, null), 0);
  });

  for (final entry in [
    (DailyGoalAutoUpdateLevel.slow, 1.05),
    (DailyGoalAutoUpdateLevel.normal, 1.1),
    (DailyGoalAutoUpdateLevel.challenging, 1.25),
  ]) {
    test('${entry.$1.name} は全ての正の指標を倍率に従って更新する', () {
      const original = DailyGoal(
        duration: Duration(seconds: 100),
        caloriesKcal: 100,
        distanceKm: 10,
      );
      final updated = DailyGoalAutoUpdate.apply(original, entry.$1);
      expect(updated.duration, Duration(seconds: (100 * entry.$2).round()));
      expect(updated.caloriesKcal, closeTo(100 * entry.$2, 1e-9));
      expect(updated.distanceKm, closeTo(10 * entry.$2, 1e-9));
      expect(original.duration, const Duration(seconds: 100));
      expect(original.caloriesKcal, 100);
      expect(original.distanceKm, 10);
    });
  }

  test('最小の正の時間と小数の目標を切り上げる', () {
    final updated = DailyGoalAutoUpdate.apply(
      const DailyGoal(
        duration: Duration(seconds: 1),
        caloriesKcal: 0.000001,
        distanceKm: 0.0000001,
      ),
      DailyGoalAutoUpdateLevel.slow,
    );
    expect(updated.duration, const Duration(seconds: 2));
    expect(updated.caloriesKcal, 0.000002);
    expect(updated.distanceKm, 0.000001);
  });

  test('0・未設定・負の目標は上方修正しない', () {
    for (final original in [
      DailyGoal.unset,
      const DailyGoal(duration: Duration.zero, caloriesKcal: 0, distanceKm: 0),
      const DailyGoal(
        duration: Duration(seconds: -1),
        caloriesKcal: -1,
        distanceKm: -1,
      ),
    ]) {
      expect(
        DailyGoalAutoUpdate.apply(
          original,
          DailyGoalAutoUpdateLevel.challenging,
        ).sameAs(original),
        isTrue,
      );
    }
  });

  test('起算日は有効化日と手動変更日の遅い方で片方だけでも動く', () {
    for (final dates in [
      (enabledOn, epoch, epoch),
      (epoch, enabledOn, epoch),
      (enabledOn, null, enabledOn),
      (null, epoch, epoch),
      (null, null, null),
    ]) {
      final settings = DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.normal,
        enabledOnLocalDate: dates.$1,
        streakEpochLocalDate: dates.$2,
      );
      expect(settings.countFromLocalDate, dates.$3);
    }
  });
}
