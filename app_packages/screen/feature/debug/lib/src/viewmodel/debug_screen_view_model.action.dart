part of 'debug_screen_view_model.dart';

/// デバッグ画面の操作。
@internal
extension DebugScreenViewModelActions on DebugScreenViewModel {
  /// 初回／再診断を実行する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onInitialize();
  /// ```
  Future<void> onInitialize() {
    return OnInitializeDelegate(
      state: state,
      diagnoseUsecase: diagnoseUsecase,
      log: log,
    ).execute();
  }

  /// ログ表示をストアへ合わせる。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onRefreshLogs();
  /// ```
  Future<void> onRefreshLogs() {
    return OnRefreshLogsDelegate(state: state, log: log).execute();
  }

  /// ログを消去する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onClearLogs();
  /// ```
  Future<void> onClearLogs() {
    return OnClearLogsDelegate(state: state, log: log).execute();
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
}
