part of 'data_management_screen_view_model.dart';

/// データ管理画面の操作。
extension DataManagementScreenViewModelAction on DataManagementScreenViewModel {
  /// 表示用 Entity のストリーム。
  ///
  /// Example:
  /// ```dart
  /// viewModel.entity;
  /// ```
  StateStream<DataManagementScreenEntity> get entity =>
      state.map(stateToEntity.convert);

  /// エクスポートを開始する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onExport();
  /// ```
  Future<void> onExport() {
    return OnExportDelegate(
      state: state,
      exportUsecase: exportUsecase,
    ).execute();
  }

  /// インポート用ファイルを選ぶ。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onImportPick();
  /// ```
  Future<void> onImportPick() {
    return OnImportPickDelegate(
      state: state,
      importUsecase: importUsecase,
    ).execute();
  }

  /// 全置換を確定して適用する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onConfirmImport();
  /// ```
  Future<void> onConfirmImport() {
    return OnConfirmImportDelegate(
      state: state,
      importUsecase: importUsecase,
      ref: ref,
    ).execute();
  }

  /// 全置換確認を取り消す。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onCancelImportConfirm();
  /// ```
  Future<void> onCancelImportConfirm() {
    return OnCancelImportConfirmDelegate(state: state).execute();
  }

  /// 戻る。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onBack();
  /// ```
  void onBack() {
    OnBackDelegate(navigation: navigation).execute();
  }
}
