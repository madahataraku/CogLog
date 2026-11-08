import 'package:infra_app_settings/infra_app_settings.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';

/// [AppSettingsOpener] を呼ぶ実装。
///
/// Example:
/// ```dart
/// OpenAppSettingsUsecaseImpl(opener: opener).execute();
/// ```
final class OpenAppSettingsUsecaseImpl implements OpenAppSettingsUsecase {
  /// [opener] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// OpenAppSettingsUsecaseImpl(opener: opener);
  /// ```
  const OpenAppSettingsUsecaseImpl({required this.opener});

  /// 設定起動口。
  final AppSettingsOpener opener;

  /// [opener] の設定起動をそのまま呼ぶ。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute();
  /// ```
  @override
  Future<void> execute() => opener.openAppSettings();
}
