part of 'app_settings_screen_view_model.dart';

/// アプリ設定の操作。
@internal
extension AppSettingsScreenViewModelActions on AppSettingsScreenViewModel {
  /// 実行情報を初回読込する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onInitialize();
  /// ```
  Future<void> onInitialize() {
    return OnInitializeDelegate(
      state: state,
      loadUsecase: loadUsecase,
    ).execute();
  }

  /// 1 つ戻る。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onBack();
  /// ```
  void onBack() {
    OnBackDelegate(navigation: navigation).execute();
  }

  /// 通知設定画面を開く。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onOpenNotificationSettings();
  /// ```
  void onOpenNotificationSettings() {
    OnOpenNotificationSettingsDelegate(navigation: navigation).execute();
  }

  /// OSS ライセンス画面を開く。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onOpenOssLicenses();
  /// ```
  void onOpenOssLicenses() {
    OnOpenOssLicensesDelegate(navigation: navigation).execute();
  }

  /// デバッグ画面を開く。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onOpenDebug();
  /// ```
  void onOpenDebug() {
    OnOpenDebugDelegate(navigation: navigation).execute();
  }
}
