import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_save_meter_capture/usecase_save_meter_capture.dart';
import 'package:usecase_health_write_guidance/usecase_health_write_guidance.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import 'delegate/meter_capture_state_to_entity_delegate.dart';
import 'delegate/on_acknowledge_model_download_guidance_delegate.dart';
import 'delegate/on_acknowledge_tutorial_camera_delegate.dart';
import 'delegate/on_acknowledge_tutorial_meter_edit_delegate.dart';
import 'delegate/on_apply_camera_status_delegate.dart';
import 'delegate/on_back_to_step1_delegate.dart';
import 'delegate/on_cancel_meter_reading_delegate.dart';
import 'delegate/on_capture_photo_delegate.dart';
import 'delegate/on_dismiss_tutorial_camera_delegate.dart';
import 'delegate/on_dismiss_tutorial_meter_edit_delegate.dart';
import 'delegate/on_evaluate_tutorial_camera_delegate.dart';
import 'delegate/on_evaluate_tutorial_meter_edit_delegate.dart';
import 'delegate/on_field_changed_delegate.dart';
import 'delegate/on_open_app_settings_delegate.dart';
import 'delegate/on_pick_library_photo_delegate.dart';
import 'delegate/on_prepare_model_download_guidance_delegate.dart';
import 'delegate/on_save_meter_capture_delegate.dart';
import 'delegate/on_suppress_tutorial_for_reading_delegate.dart';
import 'entity/meter_capture_screen_entity.dart';
import 'state/meter_capture_screen_state.dart';

part 'meter_capture_screen_view_model.action.dart';

/// メーター記録画面の状態と表示。
///
/// 可変な値は [state] だけが持つ。Usecase・誘導セッション・[ScreenNavigation] に依存する。
///
/// Example:
/// ```dart
/// MeterCaptureScreenViewModel.provider;
/// ```
@internal
final class MeterCaptureScreenViewModel {
  /// Usecase・誘導セッション・遷移を注入して作る。
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
        evaluateOnDeviceLlmGuidanceUsecase: ref.watch(
          EvaluateOnDeviceLlmGuidanceUsecase.provider,
        ),
        prepareOnDeviceLlmModelUsecase: ref.watch(
          PrepareOnDeviceLlmModelUsecase.provider,
        ),
        guidanceSession: ref.watch(ModelDownloadGuidanceProviders.session),
        evaluateTutorialContextUsecase: ref.watch(
          EvaluateTutorialContextUsecase.provider,
        ),
        markTutorialContextSeenUsecase: ref.watch(
          MarkTutorialContextSeenUsecase.provider,
        ),
        healthWriteGuidanceUsecase: ref.watch(
          HealthWriteGuidanceUsecase.provider,
        ),
        tutorialSession: ref.watch(tutorialRuntimeSessionProvider),
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
      EvaluateOnDeviceLlmGuidanceUsecase.provider,
      PrepareOnDeviceLlmModelUsecase.provider,
      ModelDownloadGuidanceProviders.session,
      EvaluateTutorialContextUsecase.provider,
      MarkTutorialContextSeenUsecase.provider,
      HealthWriteGuidanceUsecase.provider,
      tutorialRuntimeSessionProvider,
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

  /// モデル未ダウンロード誘導の要否。
  @visibleForTesting
  final EvaluateOnDeviceLlmGuidanceUsecase evaluateOnDeviceLlmGuidanceUsecase;

  /// モデル準備。
  @visibleForTesting
  final PrepareOnDeviceLlmModelUsecase prepareOnDeviceLlmModelUsecase;

  /// プロセス内の誘導再表示抑制。
  @visibleForTesting
  final OnDeviceLlmGuidanceSession guidanceSession;

  /// 文脈チュートリアルの表示要否。
  @visibleForTesting
  final EvaluateTutorialContextUsecase evaluateTutorialContextUsecase;

  /// 文脈表示済みの永続化。
  @visibleForTesting
  final MarkTutorialContextSeenUsecase markTutorialContextSeenUsecase;

  /// ヘルス書き込み案内の要否と提示済み。
  @visibleForTesting
  final HealthWriteGuidanceUsecase healthWriteGuidanceUsecase;

  /// プロセス内のチュートリアル実行状態。
  @visibleForTesting
  final TutorialRuntimeSession tutorialSession;

  /// ホームタブへの遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State から入力欄の表示文字列への変換。
  @visibleForTesting
  final MeterCaptureStateToEntityDelegate stateToEntity;

  StreamSubscription<MeterInAppCameraUiStatus>? _cameraStatusSubscription;

  /// タブ離脱／復帰と pause の直列化用世代。
  int _cameraLifecycleEpoch = 0;

  /// 進行中のカメラ開始／停止／離脱処理。
  Future<void> _cameraLifecycle = Future<void>.value();

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
    required this.evaluateOnDeviceLlmGuidanceUsecase,
    required this.prepareOnDeviceLlmModelUsecase,
    required this.guidanceSession,
    required this.evaluateTutorialContextUsecase,
    required this.markTutorialContextSeenUsecase,
    required this.healthWriteGuidanceUsecase,
    required this.tutorialSession,
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
