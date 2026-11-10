import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:infra_local_notification/infra_local_notification.dart';
import 'package:usecase_save_notification_settings/usecase_save_notification_settings.dart';
import 'package:usecase_sync_exercise_reminder/usecase_sync_exercise_reminder.dart';

/// 許可要求・保存・同期を順に行う。
///
/// Example:
/// ```dart
/// SaveNotificationSettingsUsecaseImpl(
///   settings: settings,
///   notifications: notifications,
///   sync: sync,
/// );
/// ```
final class SaveNotificationSettingsUsecaseImpl
    implements SaveNotificationSettingsUsecase {
  /// 依存を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// SaveNotificationSettingsUsecaseImpl(
  ///   settings: settings,
  ///   notifications: notifications,
  ///   sync: sync,
  /// );
  /// ```
  const SaveNotificationSettingsUsecaseImpl({
    required this.settings,
    required this.notifications,
    required this.sync,
  });

  /// 通知設定。
  final NotificationSettingsRepository settings;

  /// ローカル通知。
  final LocalNotificationGateway notifications;

  /// リマインド同期。
  final SyncExerciseReminderUsecase sync;

  /// ON なら許可を求め、結果に関わらず [request.enabled] を書き、同期する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(const SaveNotificationSettingsRequest(enabled: true));
  /// ```
  @override
  Future<SaveNotificationSettingsResult> execute(
    SaveNotificationSettingsRequest request,
  ) async {
    if (request.enabled) {
      await notifications.requestPermission();
    }
    await settings.write(NotificationSettings(enabled: request.enabled));
    final granted = await notifications.isPermissionGranted();
    await sync.execute(
      SyncExerciseReminderRequest(now: request.now ?? DateTime.now()),
    );
    return SaveNotificationSettingsResult(
      enabled: request.enabled,
      permissionGranted: granted,
    );
  }
}
