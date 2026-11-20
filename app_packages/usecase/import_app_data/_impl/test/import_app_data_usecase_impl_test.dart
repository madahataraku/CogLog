import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:data_repository_achievement_testing/data_repository_achievement_testing.dart';
import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:data_repository_notification_settings_testing/data_repository_notification_settings_testing.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:infra_local_notification_testing/infra_local_notification_testing.dart';
import 'package:infra_user_file_testing/infra_user_file_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';
import 'package:usecase_import_app_data_impl/usecase_import_app_data_impl.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

const _historyId = '11111111-1111-4111-8111-111111111111';

ExerciseHistory _history({
  String id = _historyId,
  String? healthWorkoutId = 'health-keep',
}) {
  return ExerciseHistory(
    id: id,
    savedAt: DateTime.utc(2026, 11, 5),
    creationStartedAt: DateTime.utc(2026, 11, 5, 1),
    capturedAt: DateTime.utc(2026, 11, 5, 2),
    recordedAt: DateTime.utc(2026, 11, 5, 3),
    recordedAtManuallySet: true,
    distanceKm: 2,
    duration: const Duration(minutes: 15),
    caloriesKcal: 70,
    averageSpeedKmh: 8,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
    healthWorkoutId: healthWorkoutId,
  );
}

CogsavDocument _document({
  List<ExerciseHistory>? histories,
  Map<String, Uint8List>? photos,
  NotificationSettings notificationSettings = const NotificationSettings(
    enabled: true,
  ),
}) {
  return CogsavDocument(
    formatVersion: CogsavCodec.formatVersion,
    exportedAt: DateTime.utc(2026, 11, 20),
    exerciseHistories: histories ?? [_history()],
    dailyGoal: const DailyGoal(caloriesKcal: 300),
    dailyGoalAutoUpdate: const DailyGoalAutoUpdateSettings(
      enabled: true,
      level: DailyGoalAutoUpdateLevel.slow,
      weeklyAchievementDays: 3,
    ),
    notificationSettings: notificationSettings,
    achievementUnlocks: [
      AchievementUnlock(
        id: 'first_record',
        unlockedAt: DateTime.utc(2026, 11, 10),
      ),
    ],
    achievementLastViewedAt: DateTime.utc(2026, 11, 12),
    photos:
        photos ??
        {
          _historyId: Uint8List.fromList([9, 8, 7]),
        },
  );
}

Uint8List _zipWithData(Map<String, Object?> data, {int formatVersion = 1}) {
  final archive = Archive()
    ..add(
      ArchiveFile.string(
        'manifest.json',
        jsonEncode({
          'formatVersion': formatVersion,
          'exportedAt': '2026-11-20T00:00:00.000Z',
        }),
      ),
    )
    ..add(ArchiveFile.string('data.json', jsonEncode(data)));
  return ZipEncoder().encodeBytes(archive);
}

final class _RecordingSync implements SyncExerciseReminderUsecase {
  int callCount = 0;
  bool throwOnExecute = false;

  @override
  Future<SyncExerciseReminderResult> execute(
    SyncExerciseReminderRequest request,
  ) async {
    callCount += 1;
    if (throwOnExecute) {
      throw StateError('sync failed');
    }
    return const SyncExerciseReminderResult(scheduled: false);
  }
}

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('coglog_import_uc_');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  ({
    ImportAppDataUsecaseImpl usecase,
    MemoryExerciseHistoryRepository histories,
    MemoryDailyGoalRepository goals,
    MemoryNotificationSettingsRepository notifications,
    MemoryAchievementRepository achievements,
    FakeUserFileGateway userFile,
    FakeLocalNotificationGateway localNotifications,
    _RecordingSync sync,
    ImportBackupStore backupStore,
  })
  build({
    FakeUserFileGateway? userFile,
    FakeLocalNotificationGateway? localNotifications,
    _RecordingSync? sync,
  }) {
    final histories = MemoryExerciseHistoryRepository();
    final goals = MemoryDailyGoalRepository();
    final notifications = MemoryNotificationSettingsRepository();
    final achievements = MemoryAchievementRepository();
    final files = userFile ?? FakeUserFileGateway();
    final local = localNotifications ?? FakeLocalNotificationGateway();
    final syncUsecase = sync ?? _RecordingSync();
    final backupStore = ImportBackupStore(documentsDirectory: tempDir);
    final usecase = ImportAppDataUsecaseImpl(
      histories: histories,
      goals: goals,
      notifications: notifications,
      achievements: achievements,
      userFile: files,
      localNotifications: local,
      sync: syncUsecase,
      backupStore: backupStore,
      clock: () => DateTime.utc(2026, 11, 20, 12),
    );
    return (
      usecase: usecase,
      histories: histories,
      goals: goals,
      notifications: notifications,
      achievements: achievements,
      userFile: files,
      localNotifications: local,
      sync: syncUsecase,
      backupStore: backupStore,
    );
  }

  test('pickForImport は拡張子を渡し成功バイトを返す', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final env = build(userFile: FakeUserFileGateway(pickBytesResult: bytes));
    final result = await env.usecase.pickForImport();
    expect(result, isA<ImportPickSucceeded>());
    expect((result as ImportPickSucceeded).bytes, bytes);
    expect(env.userFile.lastPickExtensions, ['cogsav', 'zip']);
  });

  test('pickForImport のキャンセルは ImportPickCancelled', () async {
    final env = build();
    expect(await env.usecase.pickForImport(), isA<ImportPickCancelled>());
  });

  test('往復で全置換しヘルス ID を null にし同期を呼ぶ', () async {
    final env = build(
      localNotifications: FakeLocalNotificationGateway(permissionGranted: true),
    );
    await env.histories.create(
      creationStartedAt: DateTime.utc(2026, 1, 1),
      capturedAt: DateTime.utc(2026, 1, 1),
      recordedAt: DateTime.utc(2026, 1, 1),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 1),
      caloriesKcal: 1,
      averageSpeedKmh: 1,
      healthWorkoutId: 'old-health',
      photoBytes: Uint8List.fromList([1]),
    );
    await env.goals.write(const DailyGoal(distanceKm: 9));
    await env.notifications.write(const NotificationSettings(enabled: false));

    final events = await env.usecase
        .applyImport(CogsavCodec.encode(_document()))
        .toList();

    expect(
      events.last,
      isA<ImportAppDataSucceeded>()
          .having((e) => e.photoMissingCount, 'photoMissingCount', 0)
          .having(
            (e) => e.notificationPermissionDenied,
            'notificationPermissionDenied',
            false,
          ),
    );
    final listed = await env.histories.list();
    expect(listed, hasLength(1));
    expect(listed.single.id, _historyId);
    expect(listed.single.healthWorkoutId, isNull);
    expect(await env.histories.readPhotoBytes(_historyId), isNotNull);
    expect((await env.goals.read()).caloriesKcal, 300);
    expect((await env.notifications.read()).enabled, isTrue);
    expect(await env.achievements.readUnlocks(), hasLength(1));
    expect(env.sync.callCount, 1);
    expect(await env.backupStore.hasMarker(), isFalse);
  });

  test('写真欠落は警告件数を返し履歴は取り込む', () async {
    final env = build();
    final events = await env.usecase
        .applyImport(CogsavCodec.encode(_document(photos: const {})))
        .toList();

    expect(
      events.last,
      isA<ImportAppDataSucceeded>().having(
        (e) => e.photoMissingCount,
        'photoMissingCount',
        1,
      ),
    );
    expect(await env.histories.list(), hasLength(1));
    expect(await env.histories.readPhotoBytes(_historyId), isNull);
  });

  test('破損バイトは書き込みなしで Failed(corrupt)', () async {
    final env = build();
    await env.goals.write(const DailyGoal(caloriesKcal: 11));
    final events = await env.usecase
        .applyImport(Uint8List.fromList([1, 2, 3]))
        .toList();

    expect(
      events.last,
      isA<ImportAppDataFailed>().having(
        (e) => e.error,
        'error',
        ImportAppDataError.corrupt,
      ),
    );
    expect((await env.goals.read()).caloriesKcal, 11);
    expect(env.sync.callCount, 0);
  });

  test('必須欠落は Failed(missingRequired) で書き込みなし', () async {
    final env = build();
    await env.goals.write(const DailyGoal(caloriesKcal: 11));
    final bytes = _zipWithData({
      'exerciseHistories': <Object?>[],
      // dailyGoal 欠落
      'dailyGoalAutoUpdate': {
        'enabled': false,
        'level': 'normal',
        'enabledOnLocalDate': null,
        'streakEpochLocalDate': null,
        'lastAppliedLocalDate': null,
        'weeklyAchievementDays': null,
      },
      'notificationSettings': {'enabled': false},
      'achievementUnlocks': <Object?>[],
      'achievementLastViewedAt': null,
    });

    final events = await env.usecase.applyImport(bytes).toList();

    expect(
      events.last,
      isA<ImportAppDataFailed>().having(
        (e) => e.error,
        'error',
        ImportAppDataError.missingRequired,
      ),
    );
    expect((await env.goals.read()).caloriesKcal, 11);
  });

  test('非対応版は Failed(unsupportedVersion)', () async {
    final env = build();
    final bytes = _zipWithData({
      'exerciseHistories': <Object?>[],
      'dailyGoal': {
        'durationSeconds': null,
        'caloriesKcal': null,
        'distanceKm': null,
      },
      'dailyGoalAutoUpdate': {
        'enabled': false,
        'level': 'normal',
        'enabledOnLocalDate': null,
        'streakEpochLocalDate': null,
        'lastAppliedLocalDate': null,
        'weeklyAchievementDays': null,
      },
      'notificationSettings': {'enabled': false},
      'achievementUnlocks': <Object?>[],
      'achievementLastViewedAt': null,
    }, formatVersion: 99);

    final events = await env.usecase.applyImport(bytes).toList();
    expect(
      events.last,
      isA<ImportAppDataFailed>().having(
        (e) => e.error,
        'error',
        ImportAppDataError.unsupportedVersion,
      ),
    );
  });

  test('適用失敗時はロールバックしバックアップを消す', () async {
    final env = build();
    await env.goals.write(const DailyGoal(caloriesKcal: 42));
    await env.notifications.write(const NotificationSettings(enabled: false));

    final failing = _FailingReplaceHistories(env.histories);
    final usecase = ImportAppDataUsecaseImpl(
      histories: failing,
      goals: env.goals,
      notifications: env.notifications,
      achievements: env.achievements,
      userFile: env.userFile,
      localNotifications: env.localNotifications,
      sync: env.sync,
      backupStore: env.backupStore,
    );

    final events = await usecase
        .applyImport(CogsavCodec.encode(_document()))
        .toList();

    expect(
      events.last,
      isA<ImportAppDataFailed>().having(
        (e) => e.error,
        'error',
        ImportAppDataError.unexpected,
      ),
    );
    expect((await env.goals.read()).caloriesKcal, 42);
    expect((await env.notifications.read()).enabled, isFalse);
    expect(await env.backupStore.hasMarker(), isFalse);
    expect(env.sync.callCount, 0);
  });

  test('同期失敗でも Succeeded を返し requestPermission は呼ばない', () async {
    final sync = _RecordingSync()..throwOnExecute = true;
    final local = FakeLocalNotificationGateway(permissionGranted: false);
    final env = build(sync: sync, localNotifications: local);

    final events = await env.usecase
        .applyImport(CogsavCodec.encode(_document()))
        .toList();

    expect(
      events.last,
      isA<ImportAppDataSucceeded>().having(
        (e) => e.notificationPermissionDenied,
        'notificationPermissionDenied',
        true,
      ),
    );
    expect(sync.callCount, 1);
    expect(local.permissionGranted, isFalse);
  });

  test('アチーブメント獲得はファイルどおりで再評価しない', () async {
    final env = build();
    await env.usecase.applyImport(CogsavCodec.encode(_document())).drain();
    final unlocks = await env.achievements.readUnlocks();
    expect(unlocks.single.id, 'first_record');
  });
}

/// [replaceAllPreservingIds] だけ失敗させるラッパ。
final class _FailingReplaceHistories implements ExerciseHistoryRepository {
  _FailingReplaceHistories(this._inner);

  final ExerciseHistoryRepository _inner;

  @override
  Future<void> replaceAllPreservingIds(
    List<ImportedExerciseHistoryEntry> entries,
  ) async {
    throw StateError('replace failed');
  }

  @override
  Future<List<ExerciseHistory>> list() => _inner.list();

  @override
  Future<List<ExerciseHistory>> listPage({
    required int year,
    required int month,
    required int offset,
    required int limit,
  }) => _inner.listPage(year: year, month: month, offset: offset, limit: limit);

  @override
  Future<List<ExerciseHistory>> listByMonth({
    required int year,
    required int month,
  }) => _inner.listByMonth(year: year, month: month);

  @override
  Future<ExerciseHistory?> findById(String id) => _inner.findById(id);

  @override
  Future<String?> photoAbsolutePath(String id) => _inner.photoAbsolutePath(id);

  @override
  Future<Uint8List?> readPhotoBytes(String id) => _inner.readPhotoBytes(id);

  @override
  Future<ExerciseHistory> create({
    required DateTime creationStartedAt,
    required DateTime capturedAt,
    required DateTime recordedAt,
    required bool recordedAtManuallySet,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
    required double averageSpeedKmh,
    required String? healthWorkoutId,
    required Uint8List photoBytes,
  }) => _inner.create(
    creationStartedAt: creationStartedAt,
    capturedAt: capturedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: recordedAtManuallySet,
    distanceKm: distanceKm,
    duration: duration,
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: averageSpeedKmh,
    healthWorkoutId: healthWorkoutId,
    photoBytes: photoBytes,
  );

  @override
  Future<ExerciseHistory> update({
    required String id,
    required DateTime creationStartedAt,
    required DateTime capturedAt,
    required DateTime recordedAt,
    required bool recordedAtManuallySet,
    required double distanceKm,
    required Duration duration,
    required double caloriesKcal,
    required double averageSpeedKmh,
    Uint8List? photoBytes,
  }) => _inner.update(
    id: id,
    creationStartedAt: creationStartedAt,
    capturedAt: capturedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: recordedAtManuallySet,
    distanceKm: distanceKm,
    duration: duration,
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: averageSpeedKmh,
    photoBytes: photoBytes,
  );

  @override
  Future<ExerciseHistory> attachHealthWorkoutId({
    required String id,
    required String healthWorkoutId,
  }) => _inner.attachHealthWorkoutId(id: id, healthWorkoutId: healthWorkoutId);

  @override
  Future<void> delete(String id) => _inner.delete(id);
}
