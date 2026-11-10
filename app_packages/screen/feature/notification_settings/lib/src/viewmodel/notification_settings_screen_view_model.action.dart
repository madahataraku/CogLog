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
    final result = await loadUsecase.execute(
      const LoadNotificationSettingsRequest(),
    );
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        NotificationSettingsScreenState(
          enabled: result.enabled,
          permissionGranted: result.permissionGranted,
          loaded: true,
        ),
      );
    });
  }

  /// ON/OFF を切り替えて保存する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onToggleEnabled(true);
  /// ```
  Future<void> onToggleEnabled(bool enabled) async {
    final result = await saveUsecase.execute(
      SaveNotificationSettingsRequest(enabled: enabled),
    );
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(
        NotificationSettingsScreenState(
          enabled: result.enabled,
          permissionGranted: result.permissionGranted,
          loaded: true,
        ),
      );
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
