import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:test/test.dart';
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';
import 'package:usecase_save_daily_goal_impl/usecase_save_daily_goal_impl.dart';

SaveDailyGoalRequest request({
  required DailyGoal goal,
  bool enabled = false,
  DailyGoalAutoUpdateLevel level = DailyGoalAutoUpdateLevel.normal,
  DateTime? now,
}) {
  return SaveDailyGoalRequest(
    goal: goal,
    autoUpdateEnabled: enabled,
    autoUpdateLevel: level,
    now: now ?? DateTime(2026, 11, 5),
  );
}

void main() {
  test('書いた目標を再び読める', () async {
    final goals = MemoryDailyGoalRepository();
    const goal = DailyGoal(
      duration: Duration(minutes: 30),
      caloriesKcal: 200,
      distanceKm: 0,
    );

    final result = await SaveDailyGoalUsecaseImpl(goals: goals)
        .execute(request(goal: goal));

    expect(result.goal.duration, const Duration(minutes: 30));
    expect(result.goal.caloriesKcal, 200);
    expect(result.goal.distanceKm, 0);
    expect(result.autoUpdate.enabled, isFalse);

    final stored = await goals.read();
    expect(stored.duration, const Duration(minutes: 30));
    expect(stored.caloriesKcal, 200);
    expect(stored.distanceKm, 0);
  });

  test('未設定を書くと未設定で読める', () async {
    final goals = MemoryDailyGoalRepository();
    await goals.write(
      const DailyGoal(duration: Duration.zero, caloriesKcal: 1, distanceKm: 2),
    );

    final result = await SaveDailyGoalUsecaseImpl(goals: goals)
        .execute(request(goal: DailyGoal.unset));

    expect(result.goal.duration, isNull);
    expect(result.goal.caloriesKcal, isNull);
    expect(result.goal.distanceKm, isNull);

    final stored = await goals.read();
    expect(stored.duration, isNull);
    expect(stored.caloriesKcal, isNull);
    expect(stored.distanceKm, isNull);
  });

  test('OFF→ON で enabledOn を today にする', () async {
    final goals = MemoryDailyGoalRepository();
    final result = await SaveDailyGoalUsecaseImpl(
      goals: goals,
    ).execute(request(goal: const DailyGoal(caloriesKcal: 100), enabled: true));
    expect(result.autoUpdate.enabled, isTrue);
    expect(result.autoUpdate.enabledOnLocalDate, DateTime(2026, 11, 5));
  });

  test('目標変更で streakEpoch を today にする', () async {
    final goals = MemoryDailyGoalRepository();
    await goals.write(const DailyGoal(caloriesKcal: 50));
    final result = await SaveDailyGoalUsecaseImpl(goals: goals)
        .execute(request(goal: const DailyGoal(caloriesKcal: 100)));
    expect(result.autoUpdate.streakEpochLocalDate, DateTime(2026, 11, 5));
  });

  test('目標書き込み失敗時は目標と設定を復元する', () async {
    final goals = _FailingGoalWriteRepository();
    await goals.writeAutoUpdateSettings(
      const DailyGoalAutoUpdateSettings(
        enabled: false,
        level: DailyGoalAutoUpdateLevel.slow,
      ),
    );

    await expectLater(
      SaveDailyGoalUsecaseImpl(goals: goals).execute(
        request(
          goal: const DailyGoal(caloriesKcal: 100),
          enabled: true,
          level: DailyGoalAutoUpdateLevel.challenging,
        ),
      ),
      throwsA(isA<StateError>()),
    );

    final settings = await goals.readAutoUpdateSettings();
    expect(settings.enabled, isFalse);
    expect(settings.enabledOnLocalDate, isNull);
    expect(settings.level, DailyGoalAutoUpdateLevel.slow);
    expect(goals.writeCallCount, 2);
    expect(goals.writtenGoals, [DailyGoal.unset]);
    expect(goals.sawEnabledSettings, isTrue);
  });
}

/// [write] の初回だけ失敗する Repository。
final class _FailingGoalWriteRepository implements DailyGoalRepository {
  /// 失敗前に保持している自動更新設定。
  DailyGoalAutoUpdateSettings _autoUpdate =
      DailyGoalAutoUpdateSettings.defaults;

  /// [write] が呼ばれた回数。
  int writeCallCount = 0;

  /// 成功した [write] に渡された目標。
  final List<DailyGoal> writtenGoals = [];

  /// 有効化後の設定が一度でも書かれたか。
  bool sawEnabledSettings = false;

  /// 未設定の目標を返す。
  ///
  /// Example:
  /// ```dart
  /// await repository.read();
  /// ```
  @override
  Future<DailyGoal> read() async => DailyGoal.unset;

  /// 初回だけ失敗し、復元の呼び出しは通す。
  ///
  /// Example:
  /// ```dart
  /// await repository.write(const DailyGoal(caloriesKcal: 100));
  /// ```
  @override
  Future<void> write(DailyGoal goal) async {
    writeCallCount += 1;
    if (writeCallCount == 1) {
      throw StateError('goal write failed');
    }
    writtenGoals.add(goal);
  }

  /// 保持中の自動更新設定を返す。
  ///
  /// Example:
  /// ```dart
  /// await repository.readAutoUpdateSettings();
  /// ```
  @override
  Future<DailyGoalAutoUpdateSettings> readAutoUpdateSettings() async =>
      _autoUpdate;

  /// 自動更新設定を上書きする。
  ///
  /// Example:
  /// ```dart
  /// await repository.writeAutoUpdateSettings(
  ///   DailyGoalAutoUpdateSettings.defaults,
  /// );
  /// ```
  @override
  Future<void> writeAutoUpdateSettings(
    DailyGoalAutoUpdateSettings settings,
  ) async {
    if (settings.enabled) {
      sawEnabledSettings = true;
    }
    _autoUpdate = settings;
  }
}
