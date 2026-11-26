import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';

import '../state/edit_camera_ui.dart';
import '../state/exercise_history_edit_phase.dart';
import '../state/exercise_history_edit_screen_state.dart';

/// 同一画面のアプリ内カメラ phase を開始する。
///
/// 写真セッション世代は進めない。キャンセルでセッションを汚さないため。
///
/// Example:
/// ```dart
/// OnRetakePhotoDelegate(
///   state: state,
///   controlMeterInAppCameraUsecase: camera,
/// ).execute();
/// ```
@internal
final class OnRetakePhotoDelegate {
  /// 画面状態とカメラ制御を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRetakePhotoDelegate(
  ///   state: state,
  ///   controlMeterInAppCameraUsecase: camera,
  /// );
  /// ```
  const OnRetakePhotoDelegate({
    required this.state,
    required this.controlMeterInAppCameraUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// アプリ内カメラ制御。
  final ControlMeterInAppCameraUsecase controlMeterInAppCameraUsecase;

  /// form からカメラ phase へ切り替え、プレビューを開始する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (state.state.reading ||
        state.state.saving ||
        state.state.loading ||
        state.state.phase == ExerciseHistoryEditPhase.camera) {
      return;
    }
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          phase: ExerciseHistoryEditPhase.camera,
          cameraUi: EditCameraUi.starting,
          cameraCapturing: false,
          cameraCaptureFailed: false,
          clearPermissionDeniedKind: true,
          saveError: false,
        ),
      );
    });
    await controlMeterInAppCameraUsecase.start();
  }
}
