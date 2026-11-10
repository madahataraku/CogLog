import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:infra_local_notification/infra_local_notification.dart';
import 'package:usecase_load_notification_settings/usecase_load_notification_settings.dart';

/// Repository と Gateway から設定と許可を読む。
///
/// Example:
/// ```dart
/// LoadNotificationSettingsUsecaseImpl(
///   settings: settings,
///   notifications: notifications,
/// );
/// ```
final class LoadNotificationSettingsUsecaseImpl
    implements LoadNotificationSettingsUsecase {
  /// 依存を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// LoadNotificationSettingsUsecaseImpl(
  ///   settings: settings,
  ///   notifications: notifications,
  /// );
  /// ```
  const LoadNotificationSettingsUsecaseImpl({
    required this.settings,
    required this.notifications,
  });

  /// 通知設定。
  final NotificationSettingsRepository settings;

  /// ローカル通知。
  final LocalNotificationGateway notifications;

  /// 設定と許可を返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(const LoadNotificationSettingsRequest());
  /// ```
  @override
  Future<LoadNotificationSettingsResult> execute(
    LoadNotificationSettingsRequest request,
  ) async {
    final current = await settings.read();
    final granted = await notifications.isPermissionGranted();
    return LoadNotificationSettingsResult(
      enabled: current.enabled,
      permissionGranted: granted,
    );
  }
}
