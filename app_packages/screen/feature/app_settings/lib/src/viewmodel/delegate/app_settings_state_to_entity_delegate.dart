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

  /// [state] を Entity にする。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsStateToEntityDelegate().execute(
  ///   AppSettingsScreenState.initial,
  /// );
  /// ```
  AppSettingsScreenEntity execute(AppSettingsScreenState state) =>
      const AppSettingsScreenEntity();
}
