import '../../strings.dart';
import '../entity/app_settings_screen_entity.dart';
import '../state/app_settings_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const AppSettingsStateToEntityDelegate();
/// ```
final class AppSettingsStateToEntityDelegate {
  /// 変換委譲を作る。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsStateToEntityDelegate();
  /// ```
  const AppSettingsStateToEntityDelegate();

  /// [state] を Entity にする。読込中・欠落時は定型文言。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsStateToEntityDelegate().execute(
  ///   AppSettingsScreenState.initial,
  /// );
  /// ```
  AppSettingsScreenEntity execute(AppSettingsScreenState state) {
    if (state.loading) {
      final text = strings.screen_feature_app_settings_info_loading;
      return AppSettingsScreenEntity(versionText: text, osText: text);
    }
    final info = state.info;
    if (info == null) {
      final text = strings.screen_feature_app_settings_info_unavailable;
      return AppSettingsScreenEntity(versionText: text, osText: text);
    }
    final osVersion = info.osVersion;
    final osText = (osVersion == null || osVersion.isEmpty)
        ? info.osName
        : '${info.osName} $osVersion';
    return AppSettingsScreenEntity(
      versionText: '${info.versionName} (${info.buildNumber})',
      osText: osText,
    );
  }
}
