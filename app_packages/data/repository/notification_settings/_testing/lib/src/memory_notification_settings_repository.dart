import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';

/// メモリ上の通知設定。初期は無効。
///
/// Example:
/// ```dart
/// MemoryNotificationSettingsRepository();
/// ```
final class MemoryNotificationSettingsRepository
    implements NotificationSettingsRepository {
  /// 無効の状態で作る。
  ///
  /// Example:
  /// ```dart
  /// MemoryNotificationSettingsRepository();
  /// ```
  MemoryNotificationSettingsRepository();

  NotificationSettings _settings = NotificationSettings.initial;

  /// まだ書いていなければ [NotificationSettings.initial]。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  @override
  Future<NotificationSettings> read() async => _settings;

  /// [settings] を次の [read] で返す。
  ///
  /// Example:
  /// ```dart
  /// repository.write(const NotificationSettings(enabled: true));
  /// ```
  @override
  Future<void> write(NotificationSettings settings) async {
    _settings = settings;
  }
}
