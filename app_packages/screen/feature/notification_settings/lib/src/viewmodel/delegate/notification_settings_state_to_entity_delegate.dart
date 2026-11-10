import '../entity/notification_settings_screen_entity.dart';
import '../state/notification_settings_screen_state.dart';

/// State を Entity へ写す。
///
/// Example:
/// ```dart
/// const NotificationSettingsStateToEntityDelegate().convert(
///   NotificationSettingsScreenState.initial,
/// );
/// ```
final class NotificationSettingsStateToEntityDelegate {
  /// 変換器を作る。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettingsStateToEntityDelegate();
  /// ```
  const NotificationSettingsStateToEntityDelegate();

  /// [state] を表示用にする。
  ///
  /// Example:
  /// ```dart
  /// delegate.convert(NotificationSettingsScreenState.initial);
  /// ```
  NotificationSettingsScreenEntity convert(
    NotificationSettingsScreenState state,
  ) {
    return NotificationSettingsScreenEntity(
      enabled: state.enabled,
      showPermissionGuidance: state.showPermissionGuidance,
      loaded: state.loaded,
    );
  }
}
