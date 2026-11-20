import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:usecase_import_app_data_impl/usecase_import_app_data_impl.dart';
import 'package:usecase_recover_interrupted_import/usecase_recover_interrupted_import.dart';

/// [ImportBackupStore] を見て復元または破棄する。
///
/// Example:
/// ```dart
/// RecoverInterruptedImportUsecaseImpl(
///   backupStore: backupStore,
///   histories: histories,
///   goals: goals,
///   notifications: notifications,
///   achievements: achievements,
/// );
/// ```
final class RecoverInterruptedImportUsecaseImpl
    implements RecoverInterruptedImportUsecase {
  /// 依存を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// RecoverInterruptedImportUsecaseImpl(
  ///   backupStore: backupStore,
  ///   histories: histories,
  ///   goals: goals,
  ///   notifications: notifications,
  ///   achievements: achievements,
  /// );
  /// ```
  const RecoverInterruptedImportUsecaseImpl({
    required this.backupStore,
    required this.histories,
    required this.goals,
    required this.notifications,
    required this.achievements,
  });

  /// バックアップ格納。
  final ImportBackupStore backupStore;

  /// 運動履歴。
  final ExerciseHistoryRepository histories;

  /// 一日あたり目標。
  final DailyGoalRepository goals;

  /// 通知設定。
  final NotificationSettingsRepository notifications;

  /// アチーブメント。
  final AchievementRepository achievements;

  /// marker 無しは noop。完全 snapshot なら復元。不完全なら破棄。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<RecoverInterruptedImportResult> execute() async {
    if (!await backupStore.hasMarker()) {
      return RecoverInterruptedImportResult.noop;
    }

    if (!await backupStore.hasRestorableSnapshot()) {
      await backupStore.clear();
      return RecoverInterruptedImportResult.discardedIncomplete;
    }

    try {
      await backupStore.restore(
        histories: histories,
        goals: goals,
        notifications: notifications,
        achievements: achievements,
      );
      await backupStore.clear();
      return RecoverInterruptedImportResult.restored;
    } on Object {
      try {
        await backupStore.clear();
      } on Object {
        // 起動継続のため clear 失敗も握りつぶす。
      }
      return RecoverInterruptedImportResult.restoreFailed;
    }
  }
}
