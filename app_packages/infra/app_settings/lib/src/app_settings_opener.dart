import 'package:riverpod/riverpod.dart';

/// OS のアプリ設定画面を開く。
///
/// Example:
/// ```dart
/// await opener.openAppSettings();
/// ```
abstract interface class AppSettingsOpener {
  /// 設定アプリを開く。
  ///
  /// Example:
  /// ```dart
  /// await opener.openAppSettings();
  /// ```
  Future<void> openAppSettings();
}

/// アプリ設定起動の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// appSettingsOpenerProvider;
/// ```
final appSettingsOpenerProvider = Provider<AppSettingsOpener>(
  (ref) => throw UnimplementedError('appSettingsOpenerProvider'),
);
