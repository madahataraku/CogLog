part of 'meter_capture_screen_view_model.dart';

/// メーター記録画面の操作。
@internal
extension MeterCaptureScreenViewModelActions on MeterCaptureScreenViewModel {
  /// アプリ内カメラを開始する。
  ///
  /// 直前の離脱／停止が完了してから開始し、より新しい操作があれば開始しない。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onEnterCamera();
  /// ```
  Future<void> onEnterCamera() {
    final epoch = ++_cameraLifecycleEpoch;
    return _enqueueCameraLifecycle(() async {
      if (epoch != _cameraLifecycleEpoch) {
        return;
      }
      await controlMeterInAppCameraUsecase.start();
    });
  }

  /// プレビューだけ止める（編集中・背面）。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onAppPaused();
  /// ```
  Future<void> onAppPaused() {
    final epoch = ++_cameraLifecycleEpoch;
    return _enqueueCameraLifecycle(() async {
      if (epoch != _cameraLifecycleEpoch) {
        return;
      }
      await controlMeterInAppCameraUsecase.stop();
    });
  }

  /// 他タブへ離れたとき、世代を進め状態を初期化する。
  ///
  /// 復帰などより新しい操作があれば、停止後の初期化は行わない。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onLeaveMeterTab();
  /// ```
  Future<void> onLeaveMeterTab() {
    final epoch = ++_cameraLifecycleEpoch;
    return _enqueueCameraLifecycle(() async {
      if (epoch != _cameraLifecycleEpoch) {
        return;
      }
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(
            cameraSessionGeneration: current.cameraSessionGeneration + 1,
          ),
        );
      });
      if (epoch != _cameraLifecycleEpoch) {
        return;
      }
      await controlMeterInAppCameraUsecase.stop();
      if (epoch != _cameraLifecycleEpoch) {
        return;
      }
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          MeterCaptureScreenState.initial.copyWith(
            cameraSessionGeneration: current.cameraSessionGeneration,
          ),
        );
      });
    });
  }

  /// カメラ開始／停止／離脱を直列化する。
  ///
  /// Example:
  /// ```dart
  /// viewModel._enqueueCameraLifecycle(() async {});
  /// ```
  Future<void> _enqueueCameraLifecycle(Future<void> Function() action) {
    final previous = _cameraLifecycle;
    final run = () async {
      try {
        await previous;
      } on Object {
        // 直前失敗でも次のライフサイクル操作を続行する。
      }
      await action();
    }();
    _cameraLifecycle = run;
    return run;
  }

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

  /// 下書きを破棄してカメラ画面へ戻る。
  ///
  /// プレビュー再開は [MeterCaptureScreen] の step 監視に任せる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onBackToStep1();
  /// ```
  Future<void> onBackToStep1() async {
    await OnBackToStep1Delegate(state: state).execute();
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

  /// 登録可能なら保存し、成功時は [OnSaveMeterCaptureSuccess] を返す。
  ///
  /// ホーム遷移は呼び出し側がトーストのあとに [goToHomeTab] する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSave();
  /// ```
  Future<OnSaveMeterCaptureSuccess?> onSave() {
    final delegate = OnSaveMeterCaptureDelegate(
      state: state,
      saveMeterCaptureUsecase: saveMeterCaptureUsecase,
    );
    return delegate.execute();
  }

  /// ホームタブへ切り替える。
  ///
  /// Example:
  /// ```dart
  /// viewModel.goToHomeTab();
  /// ```
  void goToHomeTab() => navigation.goToHomeTab();
}
