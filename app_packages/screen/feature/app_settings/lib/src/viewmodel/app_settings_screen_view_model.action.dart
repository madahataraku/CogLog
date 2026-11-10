part of 'app_settings_screen_view_model.dart';

/// アプリ設定の操作。
@internal
extension AppSettingsScreenViewModelActions on AppSettingsScreenViewModel {
  /// 1 つ戻る。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onBack();
  /// ```
  void onBack() {
    OnBackDelegate(navigation: navigation).execute();
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
