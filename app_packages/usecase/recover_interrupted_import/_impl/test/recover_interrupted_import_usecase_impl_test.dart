import 'dart:convert';
import 'dart:io';

import 'package:data_repository_achievement_testing/data_repository_achievement_testing.dart';
import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:data_repository_notification_settings_testing/data_repository_notification_settings_testing.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:test/test.dart';
import 'package:usecase_import_app_data_impl/usecase_import_app_data_impl.dart';
import 'package:usecase_recover_interrupted_import/usecase_recover_interrupted_import.dart';
import 'package:usecase_recover_interrupted_import_impl/usecase_recover_interrupted_import_impl.dart';

void main() {
  late Directory tempDir;
  late ImportBackupStore backupStore;
  late MemoryExerciseHistoryRepository histories;
  late MemoryDailyGoalRepository goals;
  late MemoryNotificationSettingsRepository notifications;
  late MemoryAchievementRepository achievements;
  late RecoverInterruptedImportUsecaseImpl usecase;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('coglog_recover_');
    backupStore = ImportBackupStore(documentsDirectory: tempDir);
    histories = MemoryExerciseHistoryRepository();
    goals = MemoryDailyGoalRepository();
    notifications = MemoryNotificationSettingsRepository();
    achievements = MemoryAchievementRepository();
    usecase = RecoverInterruptedImportUsecaseImpl(
      backupStore: backupStore,
      histories: histories,
      goals: goals,
      notifications: notifications,
      achievements: achievements,
    );
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('marker 無しは noop', () async {
    expect(await usecase.execute(), RecoverInterruptedImportResult.noop);
  });

  test('完全な snapshot があれば復元して clear する', () async {
    await goals.write(const DailyGoal(caloriesKcal: 10));
    await notifications.write(const NotificationSettings(enabled: false));
    await backupStore.createFromCurrent(
      histories: histories,
      goals: goals,
      notifications: notifications,
      achievements: achievements,
    );

    // 適用後の「壊れた」状態をシミュレート。
    await goals.write(const DailyGoal(caloriesKcal: 999));
    await notifications.write(const NotificationSettings(enabled: true));

    expect(await usecase.execute(), RecoverInterruptedImportResult.restored);
    expect((await goals.read()).caloriesKcal, 10);
    expect((await notifications.read()).enabled, isFalse);
    expect(await backupStore.hasMarker(), isFalse);
  });

  test('不完全な backup は破棄する', () async {
    final dir = backupStore.backupDirectory;
    await dir.create(recursive: true);
    await File('${dir.path}/marker.json').writeAsString(
      jsonEncode({
        'state': 'in_progress',
        'startedAt': DateTime.utc(2026, 11, 20).toIso8601String(),
      }),
    );
    // snapshot 無し

    expect(
      await usecase.execute(),
      RecoverInterruptedImportResult.discardedIncomplete,
    );
    expect(await backupStore.hasMarker(), isFalse);
  });

  test('restore 失敗でも restoreFailed を返し起動継続できる', () async {
    final dir = backupStore.backupDirectory;
    await dir.create(recursive: true);
    await File('${dir.path}/marker.json').writeAsString(
      jsonEncode({
        'state': 'in_progress',
        'startedAt': DateTime.utc(2026, 11, 20).toIso8601String(),
      }),
    );
    // デコードは通るが、restore 中の Repository 書き込みを失敗させるため
    // 壊れていないが restore が例外になるよう、snapshot を「読めるが apply で落ちる」
    // 代わりに、読めないバイトを書いて hasRestorableSnapshot が false になる経路は
    // discardedIncomplete。restoreFailed は snapshot が読め restore が投げる場合。
    final doc = CogsavDocument(
      formatVersion: CogsavCodec.formatVersion,
      exportedAt: DateTime.utc(2026, 11, 20),
      exerciseHistories: const [],
      dailyGoal: DailyGoal.unset,
      dailyGoalAutoUpdate: DailyGoalAutoUpdateSettings.defaults,
      notificationSettings: NotificationSettings.initial,
      achievementUnlocks: const [],
      achievementLastViewedAt: null,
      photos: const {},
    );
    await File('${dir.path}/snapshot.cogsav')
        .writeAsBytes(CogsavCodec.encode(doc), flush: true);

    final failingGoals = _FailingGoalWrite(goals);
    final failingUsecase = RecoverInterruptedImportUsecaseImpl(
      backupStore: backupStore,
      histories: histories,
      goals: failingGoals,
      notifications: notifications,
      achievements: achievements,
    );

    expect(
      await failingUsecase.execute(),
      RecoverInterruptedImportResult.restoreFailed,
    );
    expect(await backupStore.hasMarker(), isFalse);
  });
}

final class _FailingGoalWrite implements DailyGoalRepository {
  _FailingGoalWrite(this._inner);

  final DailyGoalRepository _inner;

  @override
  Future<DailyGoal> read() => _inner.read();

  @override
  Future<void> write(DailyGoal goal) => _inner.write(goal);

  @override
  Future<DailyGoalAutoUpdateSettings> readAutoUpdateSettings() =>
      _inner.readAutoUpdateSettings();

  @override
  Future<void> writeAutoUpdateSettings(DailyGoalAutoUpdateSettings settings) =>
      _inner.writeAutoUpdateSettings(settings);

  @override
  Future<void> writeGoalAndAutoUpdateSettings({
    required DailyGoal goal,
    required DailyGoalAutoUpdateSettings settings,
  }) async {
    throw StateError('write failed');
  }
}
