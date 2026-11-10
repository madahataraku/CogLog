import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:data_repository_notification_settings_testing/data_repository_notification_settings_testing.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:infra_local_notification_testing/infra_local_notification_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';
import 'package:usecase_sync_exercise_reminder_impl/usecase_sync_exercise_reminder_impl.dart';

import 'package:usecase_sync_exercise_reminder_impl/src/exercise_reminder_copy.dart';

ExerciseHistory history({
  required String id,
  required DateTime at,
  required Duration duration,
}) {
  return ExerciseHistory(
    id: id,
    savedAt: at,
    creationStartedAt: at,
    capturedAt: at,
    recordedAt: at,
    recordedAtManuallySet: false,
    distanceKm: 1,
    duration: duration,
    caloriesKcal: 1,
    averageSpeedKmh: 1,
    photoRelativePath: 'p/$id.jpg',
  );
}

void main() {
  test('OFF なら cancel', () async {
    final settings = MemoryNotificationSettingsRepository();
    final notifications = FakeLocalNotificationGateway(permissionGranted: true);
    final usecase = SyncExerciseReminderUsecaseImpl(
      settings: settings,
      histories: FixedExerciseHistoryRepository(const []),
      notifications: notifications,
    );
    final result = await usecase.execute(
      SyncExerciseReminderRequest(now: DateTime(2026, 11, 10, 8)),
    );
    expect(result.scheduled, isFalse);
    expect(notifications.cancelCount, 1);
  });

  test('ON・許可・候補ありなら schedule', () async {
    final settings = MemoryNotificationSettingsRepository();
    await settings.write(const NotificationSettings(enabled: true));
    final notifications = FakeLocalNotificationGateway(permissionGranted: true);
    final usecase = SyncExerciseReminderUsecaseImpl(
      settings: settings,
      histories: FixedExerciseHistoryRepository([
        history(
          id: '1',
          at: DateTime(2026, 11, 9, 18),
          duration: const Duration(hours: 1),
        ),
      ]),
      notifications: notifications,
    );
    final result = await usecase.execute(
      SyncExerciseReminderRequest(now: DateTime(2026, 11, 10, 8)),
    );
    expect(result.scheduled, isTrue);
    expect(notifications.scheduled?.when, DateTime(2026, 11, 10, 17));
    expect(
      notifications.scheduled?.title,
      anyOf(ExerciseReminderCopy.titleJa, ExerciseReminderCopy.titleEn),
    );
  });

  test('許可無しなら cancel', () async {
    final settings = MemoryNotificationSettingsRepository();
    await settings.write(const NotificationSettings(enabled: true));
    final notifications = FakeLocalNotificationGateway();
    final usecase = SyncExerciseReminderUsecaseImpl(
      settings: settings,
      histories: FixedExerciseHistoryRepository([
        history(
          id: '1',
          at: DateTime(2026, 11, 9, 18),
          duration: const Duration(hours: 1),
        ),
      ]),
      notifications: notifications,
    );
    final result = await usecase.execute(
      SyncExerciseReminderRequest(now: DateTime(2026, 11, 10, 8)),
    );
    expect(result.scheduled, isFalse);
    expect(notifications.scheduled, isNull);
  });

  test('schedule 失敗なら scheduled false', () async {
    final settings = MemoryNotificationSettingsRepository();
    await settings.write(const NotificationSettings(enabled: true));
    final notifications = FakeLocalNotificationGateway(
      permissionGranted: true,
      scheduleSucceeds: false,
    );
    final usecase = SyncExerciseReminderUsecaseImpl(
      settings: settings,
      histories: FixedExerciseHistoryRepository([
        history(
          id: '1',
          at: DateTime(2026, 11, 9, 18),
          duration: const Duration(hours: 1),
        ),
      ]),
      notifications: notifications,
    );
    final result = await usecase.execute(
      SyncExerciseReminderRequest(now: DateTime(2026, 11, 10, 8)),
    );
    expect(result.scheduled, isFalse);
    expect(notifications.scheduled, isNull);
  });
}
