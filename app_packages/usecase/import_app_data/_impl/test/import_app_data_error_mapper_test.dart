import 'dart:io';

import 'package:data_repository_achievement_testing/data_repository_achievement_testing.dart';
import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:data_repository_notification_settings_testing/data_repository_notification_settings_testing.dart';
import 'package:infra_local_notification_testing/infra_local_notification_testing.dart';
import 'package:infra_user_file_testing/infra_user_file_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';
import 'package:usecase_import_app_data_impl/usecase_import_app_data_impl.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

final class _NoopSync implements SyncExerciseReminderUsecase {
  @override
  Future<SyncExerciseReminderResult> execute(
    SyncExerciseReminderRequest request,
  ) async => const SyncExerciseReminderResult(scheduled: false);
}

ImportAppDataUsecaseImpl _usecase(FakeUserFileGateway userFile) {
  return ImportAppDataUsecaseImpl(
    histories: MemoryExerciseHistoryRepository(),
    goals: MemoryDailyGoalRepository(),
    notifications: MemoryNotificationSettingsRepository(),
    achievements: MemoryAchievementRepository(),
    userFile: userFile,
    localNotifications: FakeLocalNotificationGateway(),
    sync: _NoopSync(),
    backupStore: ImportBackupStore(documentsDirectory: Directory.systemTemp),
  );
}

void main() {
  test('選択の PathAccessException は permissionDenied', () async {
    final usecase = _usecase(
      FakeUserFileGateway(
        onPickBytes: ({required extensions}) {
          throw const PathAccessException(
            '/tmp/a.cogsav',
            OSError('denied', 13),
          );
        },
      ),
    );

    final result = await usecase.pickForImport();
    expect(
      result,
      isA<ImportPickFailed>().having(
        (e) => e.error,
        'error',
        ImportAppDataError.permissionDenied,
      ),
    );
  });

  test('選択の ENOSPC は storageFull', () async {
    final usecase = _usecase(
      FakeUserFileGateway(
        onPickBytes: ({required extensions}) {
          throw const FileSystemException(
            'read',
            '/tmp/a.cogsav',
            OSError('No space left on device', 28),
          );
        },
      ),
    );

    final result = await usecase.pickForImport();
    expect(
      result,
      isA<ImportPickFailed>().having(
        (e) => e.error,
        'error',
        ImportAppDataError.storageFull,
      ),
    );
  });
}
