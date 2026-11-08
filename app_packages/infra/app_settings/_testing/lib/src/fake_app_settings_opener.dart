import 'package:infra_app_settings/infra_app_settings.dart';

/// テスト用のアプリ設定起動。実際には開かず呼び出し回数だけ数える。
///
/// Example:
/// ```dart
/// FakeAppSettingsOpener();
/// ```
final class FakeAppSettingsOpener implements AppSettingsOpener {
  /// 記録用の実装を作る。
  ///
  /// Example:
  /// ```dart
  /// FakeAppSettingsOpener();
  /// ```
  FakeAppSettingsOpener();

  /// [openAppSettings] が呼ばれた回数。
  int openCallCount = 0;

  /// 呼び出しを記録する。
  ///
  /// Example:
  /// ```dart
  /// await FakeAppSettingsOpener().openAppSettings();
  /// ```
  @override
  Future<void> openAppSettings() async {
    openCallCount += 1;
  }
}
