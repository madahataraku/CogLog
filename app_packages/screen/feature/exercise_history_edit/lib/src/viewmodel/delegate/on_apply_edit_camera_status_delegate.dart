import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

import '../state/edit_camera_ui.dart';
import '../state/exercise_history_edit_phase.dart';
import '../state/exercise_history_edit_screen_state.dart';

/// カメラ Usecase 状態を編集画面 State へ写す。
///
/// [ExerciseHistoryEditPhase.camera] 以外では無視する。
///
/// Example:
/// ```dart
/// OnApplyEditCameraStatusDelegate(state: state).execute(
///   const MeterInAppCameraUiIdle(),
/// );
/// ```
@internal
final class OnApplyEditCameraStatusDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnApplyEditCameraStatusDelegate(state: state);
  /// ```
  const OnApplyEditCameraStatusDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// [status] を [EditCameraUi] と縦横比へ反映する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute(const MeterInAppCameraUiReady(aspectRatio: 1));
  /// ```
  Future<void> execute(MeterInAppCameraUiStatus status) async {
    await state.updateWithLock((current, emitter) async {
      if (current.phase != ExerciseHistoryEditPhase.camera) {
        return;
      }
      final next = switch (status) {
        MeterInAppCameraUiIdle() => current.copyWith(
          cameraUi: EditCameraUi.idle,
        ),
        MeterInAppCameraUiStarting() => current.copyWith(
          cameraUi: EditCameraUi.starting,
          clearPermissionDeniedKind:
              current.permissionDeniedKind == MeterPhotoPermissionKind.camera,
        ),
        MeterInAppCameraUiReady(:final aspectRatio) => current.copyWith(
          cameraUi: EditCameraUi.ready,
          cameraPreviewAspectRatio: aspectRatio,
          clearPermissionDeniedKind:
              current.permissionDeniedKind == MeterPhotoPermissionKind.camera,
          cameraCaptureFailed: false,
        ),
        MeterInAppCameraUiPermissionDenied() => current.copyWith(
          cameraUi: EditCameraUi.permissionDenied,
          permissionDeniedKind: MeterPhotoPermissionKind.camera,
        ),
        MeterInAppCameraUiFailed() => current.copyWith(
          cameraUi: EditCameraUi.failed,
          clearPermissionDeniedKind:
              current.permissionDeniedKind == MeterPhotoPermissionKind.camera,
        ),
      };
      await emitter.emit(next);
    });
  }
}
