import 'dart:typed_data';

import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:infra_local_notification/infra_local_notification.dart';
import 'package:infra_user_file/infra_user_file.dart';
import 'package:usecase_import_app_data/usecase_import_app_data.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

import 'import_app_data_error_mapper.dart';
import 'import_backup_store.dart';

/// 選択と強い原子性の適用を行う。
///
/// Example:
/// ```dart
/// ImportAppDataUsecaseImpl(
///   histories: histories,
///   goals: goals,
///   notifications: notifications,
///   achievements: achievements,
///   userFile: userFile,
///   localNotifications: localNotifications,
///   sync: sync,
///   backupStore: backupStore,
/// );
/// ```
final class ImportAppDataUsecaseImpl implements ImportAppDataUsecase {
  /// 依存を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ImportAppDataUsecaseImpl(
  ///   histories: histories,
  ///   goals: goals,
  ///   notifications: notifications,
  ///   achievements: achievements,
  ///   userFile: userFile,
  ///   localNotifications: localNotifications,
  ///   sync: sync,
  ///   backupStore: backupStore,
  /// );
  /// ```
  const ImportAppDataUsecaseImpl({
    required this.histories,
    required this.goals,
    required this.notifications,
    required this.achievements,
    required this.userFile,
    required this.localNotifications,
    required this.sync,
    required this.backupStore,
    this.clock,
  });

  /// 運動履歴。
  final ExerciseHistoryRepository histories;

  /// 一日あたり目標。
  final DailyGoalRepository goals;

  /// 通知設定。
  final NotificationSettingsRepository notifications;

  /// アチーブメント。
  final AchievementRepository achievements;

  /// 利用者ファイルの選択。
  final UserFileGateway userFile;

  /// 許可照会のみに使う（[LocalNotificationGateway.requestPermission] は呼ばない）。
  final LocalNotificationGateway localNotifications;

  /// コミット後のリマインド同期。
  final SyncExerciseReminderUsecase sync;

  /// 中断対策のバックアップ。
  final ImportBackupStore backupStore;

  /// 同期リクエストの時刻。省略時は [DateTime.now]。
  final DateTime Function()? clock;

  /// `.cogsav` / `.zip` を選ぶ。キャンセルは [ImportPickCancelled]。
  ///
  /// Example:
  /// ```dart
  /// await usecase.pickForImport();
  /// ```
  @override
  Future<ImportPickResult> pickForImport() async {
    try {
      final bytes = await userFile.pickBytes(
        extensions: const ['cogsav', 'zip'],
      );
      if (bytes == null) {
        return const ImportPickCancelled();
      }
      return ImportPickSucceeded(bytes);
    } on Object catch (error) {
      return ImportPickFailed(mapImportAppDataError(error));
    }
  }

  /// 確認済みバイトを decode → バックアップ → 適用 → クリアする。
  ///
  /// Example:
  /// ```dart
  /// await for (final event in usecase.applyImport(Uint8List(0))) {
  ///   event;
  /// }
  /// ```
  @override
  Stream<ImportAppDataEvent> applyImport(Uint8List bytes) async* {
    late final CogsavDocument document;
    try {
      yield const ImportAppDataProgress(fraction: 0.05);
      document = CogsavCodec.decode(bytes);
    } on Object catch (error) {
      yield ImportAppDataFailed(mapImportAppDataError(error));
      return;
    }

    try {
      yield const ImportAppDataProgress(fraction: 0.15);
      await backupStore.createFromCurrent(
        histories: histories,
        goals: goals,
        notifications: notifications,
        achievements: achievements,
      );

      yield const ImportAppDataProgress(fraction: 0.4);
      final photoMissingCount = await ImportBackupStore.applyDocument(
        document: document,
        histories: histories,
        goals: goals,
        notifications: notifications,
        achievements: achievements,
        clearHealthWorkoutId: true,
      );

      // コミット点: バックアップを消したらデータは確定。
      await backupStore.clear();
      yield const ImportAppDataProgress(fraction: 0.85);

      try {
        await sync.execute(
          SyncExerciseReminderRequest(now: clock?.call() ?? DateTime.now()),
        );
      } on Object {
        // 同期失敗は次回の再計算で回復する。インポート結果は返す。
      }

      final written = await notifications.read();
      final granted = await localNotifications.isPermissionGranted();
      final permissionDenied = written.enabled && !granted;

      yield ImportAppDataSucceeded(
        photoMissingCount: photoMissingCount,
        notificationPermissionDenied: permissionDenied,
      );
    } on Object catch (error) {
      try {
        await backupStore.restore(
          histories: histories,
          goals: goals,
          notifications: notifications,
          achievements: achievements,
        );
      } on Object {
        // 復元失敗でもバックアップは消し、失敗を返す。
      }
      try {
        await backupStore.clear();
      } on Object {
        // clear 失敗は握りつぶし、元の適用エラーを返す。
      }
      yield ImportAppDataFailed(mapImportAppDataError(error));
    }
  }
}
