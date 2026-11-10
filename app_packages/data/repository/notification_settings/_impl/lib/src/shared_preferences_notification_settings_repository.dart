import 'package:data_repository_notification_settings/data_repository_notification_settings.dart';
import 'package:domain_notification_settings/domain_notification_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 通知 ON/OFF を SharedPreferences の 1 キーへ残す。
///
/// Example:
/// ```dart
/// SharedPreferencesNotificationSettingsRepository(preferences).read();
/// ```
final class SharedPreferencesNotificationSettingsRepository
    implements NotificationSettingsRepository {
  /// [preferences] へ読み書きする。
  ///
  /// Example:
  /// ```dart
  /// SharedPreferencesNotificationSettingsRepository(preferences);
  /// ```
  const SharedPreferencesNotificationSettingsRepository(this._preferences);

  /// 有効フラグのキー。
  static const _enabledKey = 'notification_settings_enabled';

  /// 読み書き先。
  final SharedPreferences _preferences;

  /// キー無しは無効。
  ///
  /// Example:
  /// ```dart
  /// repository.read();
  /// ```
  @override
  Future<NotificationSettings> read() async {
    final enabled = _preferences.getBool(_enabledKey) ?? false;
    return NotificationSettings(enabled: enabled);
  }

  /// [settings.enabled] を書く。
  ///
  /// Example:
  /// ```dart
  /// repository.write(const NotificationSettings(enabled: true));
  /// ```
  @override
  Future<void> write(NotificationSettings settings) async {
    var saved = false;
    try {
      saved = await _preferences.setBool(_enabledKey, settings.enabled);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$_enabledKey を保存できなかった。');
    }
  }
}
