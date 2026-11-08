part of 'meter_capture_screen_view_model.dart';

/// メーター記録画面の操作。
@internal
extension MeterCaptureScreenViewModelActions on MeterCaptureScreenViewModel {
  /// カメラで写真を撮り、読み取りへ進む。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onCapturePhoto();
  /// ```
  Future<void> onCapturePhoto() {
    final delegate = OnCapturePhotoDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
      readMeterPanelUsecase: readMeterPanelUsecase,
    );
    return delegate.execute();
  }

  /// ライブラリから写真を選び、読み取りへ進む。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onPickLibraryPhoto();
  /// ```
  Future<void> onPickLibraryPhoto() {
    final delegate = OnPickLibraryPhotoDelegate(
      state: state,
      obtainMeterPhotoUsecase: obtainMeterPhotoUsecase,
      readMeterPanelUsecase: readMeterPanelUsecase,
    );
    return delegate.execute();
  }

  /// OS のアプリ設定を開く。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onOpenAppSettings();
  /// ```
  Future<void> onOpenAppSettings() {
    final delegate = OnOpenAppSettingsDelegate(
      openAppSettingsUsecase: openAppSettingsUsecase,
    );
    return delegate.execute();
  }

  /// 1 ステップ目へ戻り、作業中データを破棄する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onBackToStep1();
  /// ```
  Future<void> onBackToStep1() {
    final delegate = OnBackToStep1Delegate(state: state);
    return delegate.execute();
  }

  /// 走行距離を更新する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onDistanceChanged('1.5');
  /// ```
  Future<void> onDistanceChanged(String raw) {
    final delegate = OnFieldChangedDelegate(state: state);
    return delegate.updateDistance(raw);
  }

  /// 運動時間を更新する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onDurationChanged(hours: '0', minutes: '30', seconds: '0');
  /// ```
  Future<void> onDurationChanged({
    required String hours,
    required String minutes,
    required String seconds,
  }) {
    final delegate = OnFieldChangedDelegate(state: state);
    return delegate.updateDuration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  /// 消費カロリーを更新する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onCaloriesChanged('100');
  /// ```
  Future<void> onCaloriesChanged(String raw) {
    final delegate = OnFieldChangedDelegate(state: state);
    return delegate.updateCalories(raw);
  }

  /// 平均速度を更新する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onAverageSpeedChanged('12.5');
  /// ```
  Future<void> onAverageSpeedChanged(String raw) {
    final delegate = OnFieldChangedDelegate(state: state);
    return delegate.updateAverageSpeed(raw);
  }

  /// 記録日時を更新する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onRecordedAtChanged('2026-11-08T12:00:00.000');
  /// ```
  Future<void> onRecordedAtChanged(String raw) {
    final delegate = OnFieldChangedDelegate(state: state);
    return delegate.updateRecordedAt(raw);
  }

  /// 登録可能なら保存し、成功時はホームへ遷移する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSave();
  /// ```
  Future<void> onSave() {
    final delegate = OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: saveMeterCaptureUsecase,
      navigation: navigation,
    );
    return delegate.execute();
  }
}
