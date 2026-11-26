import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

import '../state/edit_camera_ui.dart';
import '../state/edit_reading_restore_snapshot.dart';
import '../state/exercise_history_edit_phase.dart';
import '../state/exercise_history_edit_screen_state.dart';
import 'apply_captured_edit_photo.dart';

/// アプリ内カメラのシャッターで写真を確定し、成功時は読み取りへ進む。
///
/// 世代はシャッター確定時にだけ進める。
///
/// Example:
/// ```dart
/// OnCaptureEditCameraDelegate(
///   state: state,
///   obtainMeterPhotoUsecase: obtain,
///   readMeterPanelUsecase: read,
///   controlMeterInAppCameraUsecase: camera,
/// ).execute();
/// ```
@internal
final class OnCaptureEditCameraDelegate {
  /// 写真取得・読み取り・カメラ停止の依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnCaptureEditCameraDelegate(
  ///   state: state,
  ///   obtainMeterPhotoUsecase: obtain,
  ///   readMeterPanelUsecase: read,
  ///   controlMeterInAppCameraUsecase: camera,
  /// );
  /// ```
  const OnCaptureEditCameraDelegate({
    required this.state,
    required this.obtainMeterPhotoUsecase,
    required this.readMeterPanelUsecase,
    required this.controlMeterInAppCameraUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// 写真取得。
  final ObtainMeterPhotoUsecase obtainMeterPhotoUsecase;

  /// パネル読み取り。
  final ReadMeterPanelUsecase readMeterPanelUsecase;

  /// アプリ内カメラ制御。
  final ControlMeterInAppCameraUsecase controlMeterInAppCameraUsecase;

  /// ready なら撮影し、成功時は form へ戻して読み取る。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (state.state.phase != ExerciseHistoryEditPhase.camera) {
      return;
    }
    if (state.state.cameraUi != EditCameraUi.ready) {
      return;
    }
    if (state.state.cameraCapturing ||
        state.state.reading ||
        state.state.saving) {
      return;
    }
    final restoreSnapshot = EditReadingRestoreSnapshot.from(state.state);
    late final int generation;
    await state.updateWithLock((current, emitter) async {
      generation = current.photoSessionGeneration + 1;
      await emitter.emit(
        current.copyWith(
          photoSessionGeneration: generation,
          cameraCapturing: true,
          cameraCaptureFailed: false,
          clearPermissionDeniedKind: true,
        ),
      );
    });

    final ObtainMeterPhotoResult result;
    try {
      result = await obtainMeterPhotoUsecase.execute(
        const ObtainMeterPhotoRequest(source: ObtainMeterPhotoSource.camera),
      );
    } on Object {
      await state.updateWithLock((current, emitter) async {
        if (current.photoSessionGeneration != generation) {
          return;
        }
        await emitter.emit(
          current.copyWith(cameraCapturing: false, cameraCaptureFailed: true),
        );
      });
      return;
    }

    if (state.state.photoSessionGeneration != generation) {
      return;
    }

    switch (result) {
      case ObtainMeterPhotoCancelled():
        await state.updateWithLock((current, emitter) async {
          if (current.photoSessionGeneration != generation) {
            return;
          }
          await emitter.emit(
            current.copyWith(cameraCapturing: false, cameraCaptureFailed: true),
          );
        });
      case ObtainMeterPhotoPermissionDenied(:final kind):
        await state.updateWithLock((current, emitter) async {
          if (current.photoSessionGeneration != generation) {
            return;
          }
          await emitter.emit(
            current.copyWith(
              cameraCapturing: false,
              cameraUi: EditCameraUi.permissionDenied,
              permissionDeniedKind: kind,
            ),
          );
        });
      case ObtainMeterPhotoSuccess(:final bytes, :final capturedAt):
        await controlMeterInAppCameraUsecase.stop();
        await state.updateWithLock((current, emitter) async {
          if (current.photoSessionGeneration != generation) {
            return;
          }
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
        await applyCapturedEditPhoto(
          state: state,
          readMeterPanelUsecase: readMeterPanelUsecase,
          bytes: bytes,
          capturedAt: capturedAt,
          restoreSnapshot: restoreSnapshot,
          generation: generation,
        );
    }
  }
}
