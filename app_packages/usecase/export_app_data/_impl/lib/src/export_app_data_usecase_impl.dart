import 'dart:io';
import 'dart:typed_data';

import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:infra_cogsav/infra_cogsav.dart';
import 'package:infra_user_file/infra_user_file.dart';
import 'package:usecase_export_app_data/usecase_export_app_data.dart';

/// 履歴・設定を読んで `.cogsav` を保存ダイアログへ渡す。
///
/// Example:
/// ```dart
/// ExportAppDataUsecaseImpl(
///   histories: histories,
///   goals: goals,
///   notifications: notifications,
///   achievements: achievements,
///   userFile: userFile,
/// );
/// ```
final class ExportAppDataUsecaseImpl implements ExportAppDataUsecase {
  /// 依存を注入して作る。
  ///
  /// [clock] はファイル名の時刻用。省略時は [DateTime.now]。
  ///
  /// Example:
  /// ```dart
  /// ExportAppDataUsecaseImpl(
  ///   histories: histories,
  ///   goals: goals,
  ///   notifications: notifications,
  ///   achievements: achievements,
  ///   userFile: userFile,
  /// );
  /// ```
  const ExportAppDataUsecaseImpl({
    required this.histories,
    required this.goals,
    required this.notifications,
    required this.achievements,
    required this.userFile,
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

  /// 利用者ファイルの保存。
  final UserFileGateway userFile;

  /// ファイル名と exportedAt 用の時計。省略時は [DateTime.now]。
  final DateTime Function()? clock;

  /// 読込・縮小・符号化・保存を進め、進捗と結果を流す。
  ///
  /// Example:
  /// ```dart
  /// await for (final event in usecase.execute()) {
  ///   event;
  /// }
  /// ```
  @override
  Stream<ExportAppDataEvent> execute() async* {
    try {
      yield const ExportAppDataProgress(fraction: 0.05);
      final listed = await histories.list();
      final photos = <String, Uint8List>{};
      for (final history in listed) {
        final bytes = await histories.readPhotoBytes(history.id);
        if (bytes != null) {
          photos[history.id] = bytes;
        }
      }

      yield const ExportAppDataProgress(fraction: 0.3);
      final dailyGoal = await goals.read();
      final autoUpdate = await goals.readAutoUpdateSettings();
      final notificationSettings = await notifications.read();
      final unlocks = await achievements.readUnlocks();
      final lastViewed = await achievements.readLastViewedAt();

      yield const ExportAppDataProgress(fraction: 0.5);
      final resized = <String, Uint8List>{};
      for (final entry in photos.entries) {
        resized[entry.key] = ExportPhotoResizer.resizeIfNeeded(entry.value);
      }

      final document = CogsavDocument(
        formatVersion: CogsavCodec.formatVersion,
        exportedAt: (clock?.call() ?? DateTime.now()).toUtc(),
        exerciseHistories: listed,
        dailyGoal: dailyGoal,
        dailyGoalAutoUpdate: autoUpdate,
        notificationSettings: notificationSettings,
        achievementUnlocks: unlocks,
        achievementLastViewedAt: lastViewed,
        photos: resized,
      );
      final bytes = CogsavCodec.encode(document);

      yield const ExportAppDataProgress(fraction: 0.8);
      final saved = await userFile.saveBytes(
        bytes: bytes,
        fileName: _exportFileName(clock?.call() ?? DateTime.now()),
        mimeType: 'application/zip',
      );
      if (saved == null) {
        yield const ExportAppDataCancelled();
        return;
      }
      yield ExportAppDataSucceeded(wasEmpty: listed.isEmpty);
    } on Object catch (error) {
      yield ExportAppDataFailed(_mapError(error));
    }
  }

  /// `coglog-YYYYMMDD-HHmmss.cogsav` を組む。
  ///
  /// Example:
  /// ```dart
  /// ExportAppDataUsecaseImpl._exportFileName(DateTime(2026, 11, 20, 18, 30, 5));
  /// ```
  static String _exportFileName(DateTime at) {
    String two(int value) => value.toString().padLeft(2, '0');
    final stamp =
        '${at.year.toString().padLeft(4, '0')}'
        '${two(at.month)}${two(at.day)}-'
        '${two(at.hour)}${two(at.minute)}${two(at.second)}';
    return 'coglog-$stamp.cogsav';
  }

  /// 例外を [ExportAppDataError] へ落とす。
  ///
  /// Example:
  /// ```dart
  /// ExportAppDataUsecaseImpl._mapError(Exception());
  /// ```
  static ExportAppDataError _mapError(Object error) {
    if (error is PathAccessException) {
      return ExportAppDataError.permissionDenied;
    }
    if (error is FileSystemException) {
      final code = error.osError?.errorCode;
      final message = '${error.message} ${error.osError?.message ?? ''}';
      if (code == 28 || message.toLowerCase().contains('no space')) {
        return ExportAppDataError.storageFull;
      }
      if (code == 13) {
        return ExportAppDataError.permissionDenied;
      }
    }
    return ExportAppDataError.unexpected;
  }
}
