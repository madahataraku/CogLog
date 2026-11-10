import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';

import 'delegate/meter_capture_state_to_entity_delegate.dart';
import 'delegate/on_apply_camera_status_delegate.dart';
import 'delegate/on_back_to_step1_delegate.dart';
import 'delegate/on_capture_photo_delegate.dart';
import 'delegate/on_field_changed_delegate.dart';
import 'delegate/on_open_app_settings_delegate.dart';
import 'delegate/on_pick_library_photo_delegate.dart';
import 'delegate/on_save_meter_capture_delegate.dart';
import 'entity/meter_capture_screen_entity.dart';
import 'state/meter_capture_screen_state.dart';

part 'meter_capture_screen_view_model.action.dart';

/// メーター記録画面の状態と表示。
///
/// 可変な値は [state] だけが持つ。Usecase と [ScreenNavigation] のみに依存する。
///
/// Example:
/// ```dart
/// MeterCaptureScreenViewModel.provider;
/// ```
@internal
final class MeterCaptureScreenViewModel {
  /// Usecase と遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(MeterCaptureScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<MeterCaptureScreenViewModel>(
    (ref) {
      final result = MeterCaptureScreenViewModel._(
        state: MutableStateStream(MeterCaptureScreenState.initial),
        obtainMeterPhotoUsecase: ref.watch(ObtainMeterPhotoUsecase.provider),
        readMeterPanelUsecase: ref.watch(ReadMeterPanelUsecase.provider),
        saveMeterCaptureUsecase: ref.watch(SaveMeterCaptureUsecase.provider),
        openAppSettingsUsecase: ref.watch(OpenAppSettingsUsecase.provider),
        controlMeterInAppCameraUsecase: ref.watch(
          ControlMeterInAppCameraUsecase.provider,
        ),
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const MeterCaptureStateToEntityDelegate(),
      );
      result._cameraStatusSubscription = result.controlMeterInAppCameraUsecase
          .watch()
          .listen((status) {
            unawaited(
              OnApplyCameraStatusDelegate(state: result.state).execute(status),
            );
          });
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      ObtainMeterPhotoUsecase.provider,
      ReadMeterPanelUsecase.provider,
      SaveMeterCaptureUsecase.provider,
      OpenAppSettingsUsecase.provider,
      ControlMeterInAppCameraUsecase.provider,
      screenNavigationProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<MeterCaptureScreenState> state;

  /// 写真取得。
  @visibleForTesting
  final ObtainMeterPhotoUsecase obtainMeterPhotoUsecase;

  /// パネル読み取り。
  @visibleForTesting
  final ReadMeterPanelUsecase readMeterPanelUsecase;

  /// メーター記録の保存。
  @visibleForTesting
  final SaveMeterCaptureUsecase saveMeterCaptureUsecase;

  /// アプリ設定を開く。
  @visibleForTesting
  final OpenAppSettingsUsecase openAppSettingsUsecase;

  /// アプリ内カメラ制御。
  @visibleForTesting
  final ControlMeterInAppCameraUsecase controlMeterInAppCameraUsecase;

  /// ホームタブへの遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State から入力欄の表示文字列への変換。
  @visibleForTesting
  final MeterCaptureStateToEntityDelegate stateToEntity;

  StreamSubscription<MeterInAppCameraUiStatus>? _cameraStatusSubscription;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// MeterCaptureScreenViewModel.provider;
  /// ```
  MeterCaptureScreenViewModel._({
    required this.state,
    required this.obtainMeterPhotoUsecase,
    required this.readMeterPanelUsecase,
    required this.saveMeterCaptureUsecase,
    required this.openAppSettingsUsecase,
    required this.controlMeterInAppCameraUsecase,
    required this.navigation,
    required this.stateToEntity,
  });

  /// 表示に使う文字列。
  StateStream<MeterCaptureScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// Widget が監視する画面状態。
  ///
  /// Example:
  /// ```dart
  /// viewModel.screenState;
  /// ```
  StateStream<MeterCaptureScreenState> get screenState => state;

  /// ライブプレビュー。
  ///
  /// Example:
  /// ```dart
  /// viewModel.buildCameraPreview();
  /// ```
  Widget buildCameraPreview({Key? key}) =>
      controlMeterInAppCameraUsecase.buildPreview(key: key);

  /// 購読と状態 Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() async {
    await _cameraStatusSubscription?.cancel();
    _cameraStatusSubscription = null;
    await controlMeterInAppCameraUsecase.stop();
    await state.close();
  }
}
