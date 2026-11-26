import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:test/test.dart';

void main() {
  const historyId = '11111111-1111-4111-8111-111111111111';

  CogsavDocument sampleDocument({
    Map<String, Uint8List> photos = const {},
    List<ExerciseHistory>? histories,
  }) {
    return CogsavDocument(
      formatVersion: CogsavCodec.formatVersion,
      exportedAt: DateTime.utc(2026, 11, 20, 12),
      exerciseHistories:
          histories ??
          [
            ExerciseHistory(
              id: historyId,
              savedAt: DateTime.utc(2026, 11, 5),
              creationStartedAt: DateTime.utc(2026, 11, 5, 1),
              capturedAt: DateTime.utc(2026, 11, 5, 2),
              recordedAt: DateTime.utc(2026, 11, 5, 3),
              recordedAtManuallySet: true,
              distanceKm: 1.5,
              duration: const Duration(minutes: 20),
              caloriesKcal: 80,
              averageSpeedKmh: 4.5,
              photoRelativePath: 'exercise_histories/$historyId/meter.jpg',
              healthWorkoutId: 'health-1',
            ),
          ],
      dailyGoal: const DailyGoal(
        duration: Duration(minutes: 30),
        caloriesKcal: 200,
        distanceKm: 5,
      ),
      dailyGoalAutoUpdate: const DailyGoalAutoUpdateSettings(
        enabled: true,
        level: DailyGoalAutoUpdateLevel.challenging,
        enabledOnLocalDate: null,
        streakEpochLocalDate: null,
        lastAppliedLocalDate: null,
        weeklyAchievementDays: 4,
      ),
      notificationSettings: const NotificationSettings(enabled: true),
      achievementUnlocks: [
        AchievementUnlock(
          id: 'first_record',
          unlockedAt: DateTime.utc(2026, 11, 10),
        ),
      ],
      achievementLastViewedAt: DateTime.utc(2026, 11, 11),
      tutorial: const TutorialProgress(
        mainCompleted: true,
        mainReachedStep: 7,
        goalSettingsContextSeen: true,
        cameraContextSeen: true,
        meterEditContextSeen: false,
        trendsContextSeen: true,
        historyContextSeen: false,
        achievementContextSeen: true,
      ),
      photos: photos,
    );
  }

  test('encode / decode 往復で値が保たれる', () {
    final original = sampleDocument(
      photos: {
        historyId: Uint8List.fromList([1, 2, 3, 4]),
      },
    );

    final decoded = CogsavCodec.decode(CogsavCodec.encode(original));

    expect(decoded.formatVersion, CogsavCodec.formatVersion);
    expect(decoded.exportedAt, original.exportedAt);
    expect(decoded.exerciseHistories, hasLength(1));
    final history = decoded.exerciseHistories.single;
    expect(history.id, historyId);
    expect(history.distanceKm, 1.5);
    expect(history.duration, const Duration(minutes: 20));
    expect(history.recordedAtManuallySet, isTrue);
    expect(history.healthWorkoutId, 'health-1');
    expect(decoded.dailyGoal.caloriesKcal, 200);
    expect(decoded.dailyGoal.duration, const Duration(minutes: 30));
    expect(
      decoded.dailyGoalAutoUpdate.level,
      DailyGoalAutoUpdateLevel.challenging,
    );
    expect(decoded.dailyGoalAutoUpdate.weeklyAchievementDays, 4);
    expect(decoded.notificationSettings.enabled, isTrue);
    expect(decoded.achievementUnlocks.single.id, 'first_record');
    expect(decoded.achievementLastViewedAt, DateTime.utc(2026, 11, 11));
    expect(decoded.tutorial?.mainCompleted, isTrue);
    expect(decoded.tutorial?.cameraContextSeen, isTrue);
    expect(decoded.tutorial?.achievementContextSeen, isTrue);
    expect(decoded.photos[historyId], Uint8List.fromList([1, 2, 3, 4]));
  });

  test('空履歴でも encode / decode できる', () {
    final original = sampleDocument(histories: const [], photos: const {});
    final decoded = CogsavCodec.decode(CogsavCodec.encode(original));
    expect(decoded.exerciseHistories, isEmpty);
    expect(decoded.photos, isEmpty);
  });

  test('非対応版は CogsavUnsupportedVersionException', () {
    final archive = Archive()
      ..add(
        ArchiveFile.string(
          'manifest.json',
          jsonEncode({
            'formatVersion': 99,
            'exportedAt': '2026-11-20T00:00:00.000Z',
          }),
        ),
      )
      ..add(
        ArchiveFile.string(
          'data.json',
          jsonEncode({
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
            'tutorial': {
              'mainCompleted': false,
              'cameraContextSeen': false,
              'meterEditContextSeen': false,
              'trendsContextSeen': false,
              'historyContextSeen': false,
              'achievementContextSeen': false,
            },
          }),
        ),
      );

    expect(
      () => CogsavCodec.decode(ZipEncoder().encodeBytes(archive)),
      throwsA(
        isA<CogsavUnsupportedVersionException>().having(
          (e) => e.formatVersion,
          'formatVersion',
          99,
        ),
      ),
    );
  });

  test('壊れた ZIP は CogsavCorruptException', () {
    expect(
      () => CogsavCodec.decode(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('許可外パスは CogsavCorruptException', () {
    final archive = Archive()
      ..add(
        ArchiveFile.string(
          'manifest.json',
          jsonEncode({
            'formatVersion': 1,
            'exportedAt': '2026-11-20T00:00:00.000Z',
          }),
        ),
      )
      ..add(ArchiveFile.string('data.json', '{}'))
      ..add(ArchiveFile.bytes('../evil.bin', [1]));

    expect(
      () => CogsavCodec.decode(ZipEncoder().encodeBytes(archive)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  Map<String, Object?> emptyDataPayload() => {
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
    'tutorial': {
      'mainCompleted': false,
      'cameraContextSeen': false,
      'meterEditContextSeen': false,
      'trendsContextSeen': false,
      'historyContextSeen': false,
      'achievementContextSeen': false,
    },
  };

  Uint8List zipWith({
    required Object? formatVersion,
    Map<String, Object?>? data,
  }) {
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
      ..add(
        ArchiveFile.string('data.json', jsonEncode(data ?? emptyDataPayload())),
      );
    return ZipEncoder().encodeBytes(archive);
  }

  test('小数の formatVersion は CogsavCorruptException', () {
    expect(
      () => CogsavCodec.decode(zipWith(formatVersion: 1.5)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('壊れた data.json は CogsavCorruptException', () {
    final archive = Archive()
      ..add(
        ArchiveFile.string(
          'manifest.json',
          jsonEncode({
            'formatVersion': 1,
            'exportedAt': '2026-11-20T00:00:00.000Z',
          }),
        ),
      )
      ..add(ArchiveFile.string('data.json', '{not-json'));
    expect(
      () => CogsavCodec.decode(ZipEncoder().encodeBytes(archive)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('必須キー欠落は CogsavCorruptException', () {
    final data = emptyDataPayload()..remove('dailyGoal');
    expect(
      () => CogsavCodec.decode(zipWith(formatVersion: 1, data: data)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('運動時間 0 の履歴は CogsavCorruptException', () {
    final data = emptyDataPayload();
    data['exerciseHistories'] = [
      {
        'id': historyId,
        'savedAt': '2026-11-05T00:00:00.000Z',
        'creationStartedAt': '2026-11-05T01:00:00.000Z',
        'capturedAt': '2026-11-05T02:00:00.000Z',
        'recordedAt': '2026-11-05T03:00:00.000Z',
        'recordedAtManuallySet': false,
        'distanceKm': 1.0,
        'durationMs': 0,
        'caloriesKcal': 1.0,
        'averageSpeedKmh': 1.0,
        'healthWorkoutId': null,
      },
    ];
    expect(
      () => CogsavCodec.decode(zipWith(formatVersion: 1, data: data)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('不正な運動履歴 ID は CogsavCorruptException', () {
    final data = emptyDataPayload();
    data['exerciseHistories'] = [
      {
        'id': '../escape',
        'savedAt': '2026-11-05T00:00:00.000Z',
        'creationStartedAt': '2026-11-05T01:00:00.000Z',
        'capturedAt': '2026-11-05T02:00:00.000Z',
        'recordedAt': '2026-11-05T03:00:00.000Z',
        'recordedAtManuallySet': false,
        'distanceKm': 1.0,
        'durationMs': 60000,
        'caloriesKcal': 1.0,
        'averageSpeedKmh': 1.0,
        'healthWorkoutId': null,
      },
    ];
    expect(
      () => CogsavCodec.decode(zipWith(formatVersion: 1, data: data)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('tutorial キー欠落は null', () {
    final data = emptyDataPayload()..remove('tutorial');
    final decoded = CogsavCodec.decode(zipWith(formatVersion: 1, data: data));
    expect(decoded.tutorial, isNull);
  });

  test('tutorial が非オブジェクトなら CogsavCorruptException', () {
    final data = emptyDataPayload();
    data['tutorial'] = true;
    expect(
      () => CogsavCodec.decode(zipWith(formatVersion: 1, data: data)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('tutorial の bool 欠落は CogsavCorruptException', () {
    final data = emptyDataPayload();
    data['tutorial'] = {'mainCompleted': true};
    expect(
      () => CogsavCodec.decode(zipWith(formatVersion: 1, data: data)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('tutorial の mainReachedStep 範囲外は CogsavCorruptException', () {
    final data = emptyDataPayload();
    data['tutorial'] = {
      'mainCompleted': false,
      'mainReachedStep': -1,
      'cameraContextSeen': false,
      'meterEditContextSeen': false,
      'trendsContextSeen': false,
      'historyContextSeen': false,
      'achievementContextSeen': false,
    };
    expect(
      () => CogsavCodec.decode(zipWith(formatVersion: 1, data: data)),
      throwsA(isA<CogsavCorruptException>()),
    );
  });

  test('tutorial の mainReachedStep 0 と 7 は復元できる', () {
    final data = emptyDataPayload();
    data['tutorial'] = {
      'mainCompleted': false,
      'mainReachedStep': 0,
      'cameraContextSeen': false,
      'meterEditContextSeen': false,
      'trendsContextSeen': false,
      'historyContextSeen': false,
      'achievementContextSeen': false,
    };
    expect(
      CogsavCodec.decode(zipWith(formatVersion: 1, data: data))
          .tutorial
          ?.mainReachedStep,
      0,
    );
    data['tutorial'] = {
      'mainCompleted': true,
      'mainReachedStep': 7,
      'cameraContextSeen': false,
      'meterEditContextSeen': false,
      'trendsContextSeen': false,
      'historyContextSeen': false,
      'achievementContextSeen': false,
    };
    expect(
      CogsavCodec.decode(zipWith(formatVersion: 1, data: data))
          .tutorial
          ?.mainReachedStep,
      7,
    );
  });

  test('encode は常に tutorial キーを出す', () {
    final decoded = CogsavCodec.decode(
      CogsavCodec.encode(
        CogsavDocument(
          formatVersion: CogsavCodec.formatVersion,
          exportedAt: DateTime.utc(2026, 11, 20),
          exerciseHistories: const [],
          dailyGoal: DailyGoal.unset,
          dailyGoalAutoUpdate: DailyGoalAutoUpdateSettings.defaults,
          notificationSettings: NotificationSettings.initial,
          achievementUnlocks: const [],
          achievementLastViewedAt: null,
          tutorial: null,
          photos: const {},
        ),
      ),
    );
    expect(decoded.tutorial, TutorialProgress.initial);
  });
}
