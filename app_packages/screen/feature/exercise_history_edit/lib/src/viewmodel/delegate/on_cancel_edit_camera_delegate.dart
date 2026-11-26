import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';

import '../state/edit_camera_ui.dart';
import '../state/exercise_history_edit_phase.dart';
import '../state/exercise_history_edit_screen_state.dart';

/// アプリ内カメラを止めて form に戻る。写真・計測・ dirty は変えない。
///
/// Example:
/// ```dart
/// OnCancelEditCameraDelegate(
///   state: state,
///   controlMeterInAppCameraUsecase: camera,
/// ).execute();
/// ```
@internal
final class OnCancelEditCameraDelegate {
  /// 画面状態とカメラ制御を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnCancelEditCameraDelegate(
  ///   state: state,
  ///   controlMeterInAppCameraUsecase: camera,
  /// );
  /// ```
  const OnCancelEditCameraDelegate({
    required this.state,
    required this.controlMeterInAppCameraUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// アプリ内カメラ制御。
  final ControlMeterInAppCameraUsecase controlMeterInAppCameraUsecase;

  /// 撮影中でなければカメラを stop し form へ戻す。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (state.state.phase != ExerciseHistoryEditPhase.camera) {
      return;
    }
    if (state.state.cameraCapturing || state.state.reading) {
      return;
    }
    await controlMeterInAppCameraUsecase.stop();
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          phase: ExerciseHistoryEditPhase.form,
          cameraUi: EditCameraUi.idle,
          cameraCapturing: false,
          cameraCaptureFailed: false,
          clearCameraPreviewAspectRatio: true,
        ),
      );
    });
  }
}
