import 'dart:math' as math;
import 'dart:typed_data';

import 'package:data_repository_achievement_testing/data_repository_achievement_testing.dart';
import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:data_repository_notification_settings_testing/data_repository_notification_settings_testing.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:image/image.dart' as img;
import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:infra_user_file_testing/infra_user_file_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_export_app_data/usecase_export_app_data.dart';
import 'package:usecase_export_app_data_impl/usecase_export_app_data_impl.dart';

Uint8List _jpeg({required int width, required int height}) {
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(10, 20, 30));
  return Uint8List.fromList(img.encodeJpg(image, quality: 90));
}

void main() {
  final fixedNow = DateTime(2026, 11, 20, 18, 30, 5);

  ExportAppDataUsecaseImpl build({
    required MemoryExerciseHistoryRepository histories,
    required FakeUserFileGateway userFile,
    MemoryDailyGoalRepository? goals,
    MemoryNotificationSettingsRepository? notifications,
    MemoryAchievementRepository? achievements,
  }) {
    return ExportAppDataUsecaseImpl(
      histories: histories,
      goals: goals ?? MemoryDailyGoalRepository(),
      notifications: notifications ?? MemoryNotificationSettingsRepository(),
      achievements: achievements ?? MemoryAchievementRepository(),
      userFile: userFile,
      clock: () => fixedNow,
    );
  }

  test('履歴と設定を書いて保存に成功する', () async {
    final histories = MemoryExerciseHistoryRepository();
    final photo = _jpeg(width: 100, height: 80);
    final created = await histories.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 10),
      caloriesKcal: 50,
      averageSpeedKmh: 6,
      healthWorkoutId: 'health-1',
      photoBytes: photo,
    );
    final goals = MemoryDailyGoalRepository();
    await goals.write(const DailyGoal(caloriesKcal: 200));
    final notifications = MemoryNotificationSettingsRepository();
    await notifications.write(const NotificationSettings(enabled: true));
    final achievements = MemoryAchievementRepository();
    await achievements.mergeUnlocks([
      AchievementUnlock(
        id: 'first_record',
        unlockedAt: DateTime.utc(2026, 11, 10),
      ),
    ]);
    await achievements.writeLastViewedAt(DateTime.utc(2026, 11, 11));

    final userFile = FakeUserFileGateway(
      saveBytesResult: Uri.parse('file:///tmp/out.cogsav'),
    );
    final events = await build(
      histories: histories,
      userFile: userFile,
      goals: goals,
      notifications: notifications,
      achievements: achievements,
    ).execute().toList();

    expect(events.whereType<ExportAppDataProgress>(), isNotEmpty);
    expect(
      events.last,
      isA<ExportAppDataSucceeded>().having(
        (e) => e.wasEmpty,
        'wasEmpty',
        false,
      ),
    );
    expect(userFile.saveCallCount, 1);
    expect(userFile.lastSave?.fileName, 'coglog-20261120-183005.cogsav');
    expect(userFile.lastSave?.mimeType, 'application/zip');

    final decoded = CogsavCodec.decode(userFile.lastSave!.bytes);
    expect(decoded.exerciseHistories.single.id, created.id);
    expect(decoded.dailyGoal.caloriesKcal, 200);
    expect(decoded.notificationSettings.enabled, isTrue);
    expect(decoded.achievementUnlocks, hasLength(1));
    expect(decoded.achievementLastViewedAt, DateTime.utc(2026, 11, 11));
    expect(decoded.photos.containsKey(created.id), isTrue);
  });

  test('履歴が空でも設定のみのファイルを書き wasEmpty が true', () async {
    final userFile = FakeUserFileGateway(
      saveBytesResult: Uri.parse('file:///tmp/empty.cogsav'),
    );
    final events = await build(
      histories: MemoryExerciseHistoryRepository(),
      userFile: userFile,
    ).execute().toList();

    expect(
      events.last,
      isA<ExportAppDataSucceeded>().having((e) => e.wasEmpty, 'wasEmpty', true),
    );
    final decoded = CogsavCodec.decode(userFile.lastSave!.bytes);
    expect(decoded.exerciseHistories, isEmpty);
  });

  test('保存キャンセルは Cancelled を返す', () async {
    final userFile = FakeUserFileGateway();
    final events = await build(
      histories: MemoryExerciseHistoryRepository(),
      userFile: userFile,
    ).execute().toList();

    expect(events.last, isA<ExportAppDataCancelled>());
    expect(userFile.saveCallCount, 1);
  });

  test('長辺 600px 以上の写真は縮小される', () async {
    final histories = MemoryExerciseHistoryRepository();
    final large = _jpeg(width: 1200, height: 800);
    final created = await histories.create(
      creationStartedAt: DateTime.utc(2026, 11, 5),
      capturedAt: DateTime.utc(2026, 11, 5),
      recordedAt: DateTime.utc(2026, 11, 5),
      recordedAtManuallySet: false,
      distanceKm: 1,
      duration: const Duration(minutes: 5),
      caloriesKcal: 20,
      averageSpeedKmh: 5,
      healthWorkoutId: null,
      photoBytes: large,
    );
    final userFile = FakeUserFileGateway(
      saveBytesResult: Uri.parse('file:///tmp/resized.cogsav'),
    );

    await build(histories: histories, userFile: userFile).execute().toList();

    final decoded = CogsavCodec.decode(userFile.lastSave!.bytes);
    final exported = decoded.photos[created.id]!;
    expect(exported.lengthInBytes, lessThan(large.lengthInBytes));
    final image = img.decodeImage(exported)!;
    expect(math.max(image.width, image.height), ExportPhotoResizer.maxLongSide);
  });

  test('保存例外は Failed にマップする', () async {
    final userFile = FakeUserFileGateway(
      onSaveBytes:
          ({
            required Uint8List bytes,
            required String fileName,
            required String mimeType,
          }) {
            throw Exception('boom');
          },
    );
    final events = await build(
      histories: MemoryExerciseHistoryRepository(),
      userFile: userFile,
    ).execute().toList();

    expect(
      events.last,
      isA<ExportAppDataFailed>().having(
        (e) => e.error,
        'error',
        ExportAppDataError.unexpected,
      ),
    );
  });
}
