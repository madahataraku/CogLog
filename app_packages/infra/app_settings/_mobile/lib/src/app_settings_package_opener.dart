import 'package:app_settings/app_settings.dart';
import 'package:infra_app_settings/infra_app_settings.dart';

/// [AppSettings] プラグインで OS のアプリ設定を開く。
///
/// Example:
/// ```dart
/// const AppSettingsPackageOpener();
/// ```
final class AppSettingsPackageOpener implements AppSettingsOpener {
  /// プラグイン経由の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsPackageOpener();
  /// ```
  const AppSettingsPackageOpener();

  /// アプリ設定画面を開く。
  ///
  /// Example:
  /// ```dart
  /// await const AppSettingsPackageOpener().openAppSettings();
  /// ```
  @override
  Future<void> openAppSettings() => AppSettings.openAppSettings();
}
