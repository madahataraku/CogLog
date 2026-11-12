import 'package:meta/meta.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';

/// OS のアプリ設定を開く。
///
/// Example:
/// ```dart
/// OnOpenAppSettingsDelegate(
///   openAppSettingsUsecase: openAppSettingsUsecase,
/// ).execute();
/// ```
@internal
final class OnOpenAppSettingsDelegate {
  /// 設定を開く Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenAppSettingsDelegate(
  ///   openAppSettingsUsecase: openAppSettingsUsecase,
  /// );
  /// ```
  const OnOpenAppSettingsDelegate({required this.openAppSettingsUsecase});

  /// アプリ設定を開く。
  final OpenAppSettingsUsecase openAppSettingsUsecase;

  /// 設定画面を開く。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() => openAppSettingsUsecase.execute();
}
