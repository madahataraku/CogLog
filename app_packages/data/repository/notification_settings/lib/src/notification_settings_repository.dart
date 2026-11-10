import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:riverpod/riverpod.dart';

/// 通知設定をプロセス終了後も残す。
///
/// Example:
/// ```dart
/// repository.read();
/// ```
abstract interface class NotificationSettingsRepository {
  /// 保存が無ければ [NotificationSettings.initial]。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  Future<NotificationSettings> read();

  /// [settings] を保存する。
  ///
  /// Example:
  /// ```dart
  /// repository.write(const NotificationSettings(enabled: true));
  /// ```
  Future<void> write(NotificationSettings settings);
}

/// 通知設定 Repository の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// notificationSettingsRepositoryProvider;
/// ```
final notificationSettingsRepositoryProvider =
    Provider<NotificationSettingsRepository>(
      (ref) =>
          throw UnimplementedError('notificationSettingsRepositoryProvider'),
    );
