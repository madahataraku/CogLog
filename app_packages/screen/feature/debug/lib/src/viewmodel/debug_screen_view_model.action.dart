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
      diagnoseMeterVlUsecase: diagnoseMeterVlUsecase,
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

  /// LFM VL 優先モードを [preferLfmVl] に切り替える。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onTogglePreferLfmVl(true);
  /// ```
  Future<void> onTogglePreferLfmVl(bool preferLfmVl) {
    return OnTogglePreferLfmVlDelegate(
      state: state,
      sessionPreference: sessionPreference,
    ).execute(preferLfmVl);
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

  /// 確認ダイアログ後に LFM VL 再ダウンロードを開始する。
  ///
  /// 本体は [OnRedownloadMeterVlDelegate.execute]。
  /// busy 拒否時は conflict 理由を残すがボタンは有効のまま。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onRedownloadMeterVl();
  /// ```
  Future<bool> onRedownloadMeterVl() {
    return OnRedownloadMeterVlDelegate(
      session: redownloadSession,
      usecase: redownloadUsecase,
      state: state,
    ).execute();
  }

  /// 再ダウンロード確定後の再診断が終わったことを session へ伝える。
  ///
  /// 本体は [OnAcknowledgeRedownloadDiagnoseRefreshDelegate.execute]。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onAcknowledgeRedownloadDiagnoseRefresh();
  /// ```
  Future<void> onAcknowledgeRedownloadDiagnoseRefresh() {
    return OnAcknowledgeRedownloadDiagnoseRefreshDelegate(
      session: redownloadSession,
    ).execute();
  }

  /// session スナップショットを [DebugScreenState] へ写す。
  ///
  /// 本体は [OnRedownloadSessionSyncDelegate.execute]。
  /// provider 購読開始時の即時同期と stream 更新の両方から呼ばれる。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onRedownloadSessionSync(sessionState);
  /// ```
  Future<void> onRedownloadSessionSync(
    MeterVlRedownloadSessionState sessionState,
  ) {
    return OnRedownloadSessionSyncDelegate(state: state).execute(sessionState);
  }
}
