import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';

/// OS のアプリ設定画面を開く。
///
/// Example:
/// ```dart
/// OnOpenAppSettingsDelegate(
///   openAppSettingsUsecase: openAppSettingsUsecase,
/// ).execute();
/// ```
final class OnOpenAppSettingsDelegate {
  /// [openAppSettingsUsecase] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenAppSettingsDelegate(
  ///   openAppSettingsUsecase: openAppSettingsUsecase,
  /// );
  /// ```
  const OnOpenAppSettingsDelegate({required this.openAppSettingsUsecase});

  /// 設定を開く Usecase。
  final OpenAppSettingsUsecase openAppSettingsUsecase;

  /// 設定アプリを開く。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() => openAppSettingsUsecase.execute();
}
