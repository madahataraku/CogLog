import 'dart:async';
import 'dart:typed_data';

import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:data_repository_tutorial/data_repository_tutorial.dart';
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
///   tutorial: tutorial,
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
  ///   tutorial: tutorial,
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
    required this.tutorial,
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

  /// チュートリアル進捗。
  final TutorialRepository tutorial;

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
  /// バックアップ作成からコミット／ロールバックまでは [ImportBackupStore.runExclusive]
  /// で直列化する。購読キャンセル時も未コミットなら復元を試み、復元失敗時は
  /// バックアップを残して次回起動復旧に委ねる。
  ///
  /// Example:
  /// ```dart
  /// await for (final event in usecase.applyImport(Uint8List(0))) {
  ///   event;
  /// }
  /// ```
  @override
  Stream<ImportAppDataEvent> applyImport(Uint8List bytes) {
    var cancelled = false;
    late final StreamController<ImportAppDataEvent> controller;
    controller = StreamController<ImportAppDataEvent>(
      onCancel: () {
        cancelled = true;
      },
    );

    () async {
      late final CogsavDocument document;
      try {
        _addEvent(controller, const ImportAppDataProgress(fraction: 0.05));
        document = CogsavCodec.decode(bytes);
      } on Object catch (error) {
        _addEvent(
          controller,
          ImportAppDataFailed(mapImportAppDataError(error)),
        );
        await controller.close();
        return;
      }

      var backupCreated = false;
      var committed = false;
      try {
        await backupStore.runExclusive(() async {
          if (cancelled) {
            return;
          }
          _addEvent(controller, const ImportAppDataProgress(fraction: 0.15));
          await backupStore.createFromCurrent(
            histories: histories,
            goals: goals,
            notifications: notifications,
            achievements: achievements,
            tutorial: tutorial,
          );
          backupCreated = true;
          if (cancelled) {
            return;
          }

          _addEvent(controller, const ImportAppDataProgress(fraction: 0.4));
          final photoMissingCount = await ImportBackupStore.applyDocument(
            document: document,
            histories: histories,
            goals: goals,
            notifications: notifications,
            achievements: achievements,
            tutorial: tutorial,
            clearHealthWorkoutId: true,
          );
          if (cancelled) {
            return;
          }

          // コミット点: バックアップを消したらデータは確定。
          await backupStore.clear();
          committed = true;
          _addEvent(controller, const ImportAppDataProgress(fraction: 0.85));

          // 以降はコミット後。失敗してもインポート成功を返す。
          try {
            await sync.execute(
              SyncExerciseReminderRequest(now: clock?.call() ?? DateTime.now()),
            );
          } on Object {
            // 同期失敗は次回の再計算で回復する。
          }

          var permissionDenied = false;
          try {
            final written = await notifications.read();
            final granted = await localNotifications.isPermissionGranted();
            permissionDenied = written.enabled && !granted;
          } on Object {
            // 許可照会失敗は案内なしとして成功を返す。
          }

          _addEvent(
            controller,
            ImportAppDataSucceeded(
              photoMissingCount: photoMissingCount,
              notificationPermissionDenied: permissionDenied,
            ),
          );
        });
      } on Object catch (error) {
        if (!controller.isClosed) {
          _addEvent(
            controller,
            ImportAppDataFailed(mapImportAppDataError(error)),
          );
        }
      } finally {
        if (backupCreated && !committed) {
          await _restoreKeepingBackupOnFailure();
        }
        if (!controller.isClosed) {
          await controller.close();
        }
      }
    }();

    return controller.stream;
  }

  void _addEvent(
    StreamController<ImportAppDataEvent> controller,
    ImportAppDataEvent event,
  ) {
    if (!controller.isClosed) {
      controller.add(event);
    }
  }

  /// 未コミット時に復元する。復元成功時だけバックアップを消す。
  Future<void> _restoreKeepingBackupOnFailure() async {
    try {
      await backupStore.restore(
        histories: histories,
        goals: goals,
        notifications: notifications,
        achievements: achievements,
        tutorial: tutorial,
      );
      await backupStore.clear();
    } on Object {
      // 復元失敗時はバックアップを残し、起動時復旧に委ねる。
    }
  }
}
