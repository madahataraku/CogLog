part of 'notification_settings_screen_view_model.dart';

/// 通知設定画面の操作。
extension NotificationSettingsScreenViewModelAction
    on NotificationSettingsScreenViewModel {
  /// 表示用 Entity のストリーム。
  ///
  /// Example:
  /// ```dart
  /// viewModel.entity;
  /// ```
  StateStream<NotificationSettingsScreenEntity> get entity =>
      state.map(stateToEntity.convert);

  /// 初回読み込み。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onInitialize();
  /// ```
  Future<void> onInitialize() async {
    await state.updateWithLock((current, emitter) async {
      try {
        final result = await loadUsecase.execute(
          const LoadNotificationSettingsRequest(),
        );
        await emitter.emit(
          NotificationSettingsScreenState(
            enabled: result.enabled,
            permissionGranted: result.permissionGranted,
            loaded: true,
          ),
        );
      } on Object {
        // 読み込み失敗時は未読込のままにし、再表示で回復する。
        if (!current.loaded) {
          return;
        }
      }
    });
  }

  /// ON/OFF を切り替えて保存する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onToggleEnabled(true);
  /// ```
  Future<void> onToggleEnabled(bool enabled) async {
    await state.updateWithLock((current, emitter) async {
      if (!current.loaded) {
        return;
      }
      try {
        final result = await saveUsecase.execute(
          SaveNotificationSettingsRequest(enabled: enabled),
        );
        await emitter.emit(
          NotificationSettingsScreenState(
            enabled: result.enabled,
            permissionGranted: result.permissionGranted,
            loaded: true,
          ),
        );
      } on Object {
        // 保存失敗時は表示を変えず、元のスイッチ状態を保つ。
      }
    });
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
