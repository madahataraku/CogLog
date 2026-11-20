import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:meta/meta.dart';

/// `{documents}/cogsav_import_backup/` への現行データ退避と復元。
///
/// `marker.json` と `snapshot.cogsav`（現行内容の `.cogsav`）で中断復旧する。
///
/// Example:
/// ```dart
/// ImportBackupStore(documentsDirectory: Directory.systemTemp);
/// ```
final class ImportBackupStore {
  /// [documentsDirectory] 直下にバックアップ用サブディレクトリを置く。
  ///
  /// Example:
  /// ```dart
  /// ImportBackupStore(documentsDirectory: Directory.systemTemp);
  /// ```
  ImportBackupStore({required this.documentsDirectory});

  /// アプリの Documents ディレクトリ。
  final Directory documentsDirectory;

  /// バックアップルート。
  ///
  /// Example:
  /// ```dart
  /// ImportBackupStore(documentsDirectory: Directory.systemTemp).backupDirectory;
  /// ```
  Directory get backupDirectory =>
      Directory('${documentsDirectory.path}/cogsav_import_backup');

  File get _markerFile => File('${backupDirectory.path}/marker.json');

  File get _snapshotFile => File('${backupDirectory.path}/snapshot.cogsav');

  /// marker.json があるか。
  ///
  /// Example:
  /// ```dart
  /// await store.hasMarker();
  /// ```
  Future<bool> hasMarker() async => _markerFile.exists();

  /// 復元可能な snapshot.cogsav があるか。
  ///
  /// Example:
  /// ```dart
  /// await store.hasRestorableSnapshot();
  /// ```
  Future<bool> hasRestorableSnapshot() async {
    if (!await _snapshotFile.exists()) {
      return false;
    }
    try {
      CogsavCodec.decode(await _snapshotFile.readAsBytes());
      return true;
    } on Object {
      return false;
    }
  }

  /// 現行 Repository 内容をバックアップし、marker を in_progress にする。
  ///
  /// Example:
  /// ```dart
  /// await store.createFromCurrent(
  ///   histories: histories,
  ///   goals: goals,
  ///   notifications: notifications,
  ///   achievements: achievements,
  /// );
  /// ```
  Future<void> createFromCurrent({
    required ExerciseHistoryRepository histories,
    required DailyGoalRepository goals,
    required NotificationSettingsRepository notifications,
    required AchievementRepository achievements,
  }) async {
    await clear();
    await backupDirectory.create(recursive: true);
    await _writeMarker(state: 'in_progress');

    final listed = await histories.list();
    final photos = <String, Uint8List>{};
    for (final history in listed) {
      final bytes = await histories.readPhotoBytes(history.id);
      if (bytes != null) {
        photos[history.id] = bytes;
      }
    }

    final document = CogsavDocument(
      formatVersion: CogsavCodec.formatVersion,
      exportedAt: DateTime.now().toUtc(),
      exerciseHistories: listed,
      dailyGoal: await goals.read(),
      dailyGoalAutoUpdate: await goals.readAutoUpdateSettings(),
      notificationSettings: await notifications.read(),
      achievementUnlocks: await achievements.readUnlocks(),
      achievementLastViewedAt: await achievements.readLastViewedAt(),
      photos: photos,
    );
    await _snapshotFile.writeAsBytes(CogsavCodec.encode(document), flush: true);
  }

  /// バックアップから Repository へ書き戻す。
  ///
  /// Example:
  /// ```dart
  /// await store.restore(
  ///   histories: histories,
  ///   goals: goals,
  ///   notifications: notifications,
  ///   achievements: achievements,
  /// );
  /// ```
  Future<void> restore({
    required ExerciseHistoryRepository histories,
    required DailyGoalRepository goals,
    required NotificationSettingsRepository notifications,
    required AchievementRepository achievements,
  }) async {
    await _writeMarker(state: 'restoring');
    final document = CogsavCodec.decode(await _snapshotFile.readAsBytes());
    await applyDocument(
      document: document,
      histories: histories,
      goals: goals,
      notifications: notifications,
      achievements: achievements,
      clearHealthWorkoutId: false,
    );
  }

  /// バックアップディレクトリを削除する。
  ///
  /// Example:
  /// ```dart
  /// await store.clear();
  /// ```
  Future<void> clear() async {
    if (await backupDirectory.exists()) {
      await backupDirectory.delete(recursive: true);
    }
  }

  /// [document] を各 Repository へ適用する。
  ///
  /// [clearHealthWorkoutId] が true のときヘルス ID をすべて null にする。
  /// 戻り値は写真欠落件数。最終閲覧が null のときは write を呼ばない
  ///（Repository に消去 API が無い）。
  ///
  /// Example:
  /// ```dart
  /// await ImportBackupStore.applyDocument(
  ///   document: document,
  ///   histories: histories,
  ///   goals: goals,
  ///   notifications: notifications,
  ///   achievements: achievements,
  ///   clearHealthWorkoutId: true,
  /// );
  /// ```
  @internal
  static Future<int> applyDocument({
    required CogsavDocument document,
    required ExerciseHistoryRepository histories,
    required DailyGoalRepository goals,
    required NotificationSettingsRepository notifications,
    required AchievementRepository achievements,
    required bool clearHealthWorkoutId,
  }) async {
    var photoMissingCount = 0;
    final entries = <ImportedExerciseHistoryEntry>[];
    for (final history in document.exerciseHistories) {
      final photoBytes = document.photos[history.id];
      if (photoBytes == null) {
        photoMissingCount += 1;
      }
      final cleared = clearHealthWorkoutId
          ? ExerciseHistory(
              id: history.id,
              savedAt: history.savedAt,
              creationStartedAt: history.creationStartedAt,
              capturedAt: history.capturedAt,
              recordedAt: history.recordedAt,
              recordedAtManuallySet: history.recordedAtManuallySet,
              distanceKm: history.distanceKm,
              duration: history.duration,
              caloriesKcal: history.caloriesKcal,
              averageSpeedKmh: history.averageSpeedKmh,
              photoRelativePath: history.photoRelativePath,
              healthWorkoutId: null,
            )
          : history;
      entries.add(
        ImportedExerciseHistoryEntry(history: cleared, photoBytes: photoBytes),
      );
    }

    await histories.replaceAllPreservingIds(entries);
    await goals.writeGoalAndAutoUpdateSettings(
      goal: document.dailyGoal,
      settings: document.dailyGoalAutoUpdate,
    );
    await notifications.write(document.notificationSettings);
    await achievements.replaceUnlocks(document.achievementUnlocks);
    final lastViewed = document.achievementLastViewedAt;
    if (lastViewed != null) {
      await achievements.writeLastViewedAt(lastViewed);
    }
    return photoMissingCount;
  }

  Future<void> _writeMarker({required String state}) async {
    await backupDirectory.create(recursive: true);
    final payload = <String, Object?>{
      'state': state,
      'startedAt': DateTime.now().toUtc().toIso8601String(),
    };
    await _markerFile.writeAsString(jsonEncode(payload), flush: true);
  }
}
