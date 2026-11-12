part of 'exercise_history_edit_screen_view_model.dart';

/// 運動履歴編集の操作。
@internal
extension ExerciseHistoryEditScreenViewModelActions
    on ExerciseHistoryEditScreenViewModel {
  /// [id] の詳細を読み込む。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onInitialize(id: 'id');
  /// ```
  Future<void> onInitialize({required String id}) {
    return OnInitializeDelegate(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
    ).execute(id: id);
  }

  /// 走行距離を更新する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onDistanceChanged('1.5');
  /// ```
  Future<void> onDistanceChanged(String raw) {
    return OnFieldChangedDelegate(state: state).updateDistance(raw);
  }

  /// 運動時間を更新する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onDurationChanged(
  ///   hours: '0',
  ///   minutes: '30',
  ///   seconds: '0',
  /// );
  /// ```
  Future<void> onDurationChanged({
    required String hours,
    required String minutes,
    required String seconds,
  }) {
    return OnFieldChangedDelegate(state: state)
        .updateDuration(hours: hours, minutes: minutes, seconds: seconds);
  }

  /// 消費カロリーを更新する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onCaloriesChanged('100');
  /// ```
  Future<void> onCaloriesChanged(String raw) {
    return OnFieldChangedDelegate(state: state).updateCalories(raw);
  }

  /// 運動した日時を更新する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onRecordedAtChanged(DateTime(2026, 11, 8, 12));
  /// ```
  Future<void> onRecordedAtChanged(DateTime value) {
    return OnFieldChangedDelegate(state: state).updateRecordedAt(value);
  }

  /// カメラで写真を撮り直す。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onRetakePhoto();
  /// ```
  Future<void> onRetakePhoto() {
    return OnRetakePhotoDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
      readMeterPanelUsecase: readMeterPanelUsecase,
    ).execute();
  }

  /// ライブラリから写真を選ぶ。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onPickLibraryPhoto();
  /// ```
  Future<void> onPickLibraryPhoto() {
    return OnPickLibraryPhotoDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
      readMeterPanelUsecase: readMeterPanelUsecase,
    ).execute();
  }

  /// 編集を保存する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onSave();
  /// ```
  Future<void> onSave() {
    return OnSaveDelegate(
      state: state,
      updateUsecase: updateUsecase,
      navigation: navigation,
    ).execute();
  }

  /// 未保存変更を捨てて閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onDiscard();
  /// ```
  void onDiscard() {
    OnDiscardDelegate(navigation: navigation).execute();
  }

  /// OS のアプリ設定を開く。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onOpenAppSettings();
  /// ```
  Future<void> onOpenAppSettings() {
    return OnOpenAppSettingsDelegate(
      openAppSettingsUsecase: openAppSettingsUsecase,
    ).execute();
  }
}
