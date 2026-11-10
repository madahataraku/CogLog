import 'package:state_stream/state_stream.dart';
import 'package:usecase_control_meter_in_app_camera/usecase_control_meter_in_app_camera.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';

import '../state/meter_capture_camera_ui.dart';
import '../state/meter_capture_screen_state.dart';

/// カメラ Usecase 状態を画面 State へ写す。
///
/// Example:
/// ```dart
/// OnApplyCameraStatusDelegate(state: state).execute(const MeterInAppCameraUiIdle());
/// ```
final class OnApplyCameraStatusDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnApplyCameraStatusDelegate(state: state);
  /// ```
  const OnApplyCameraStatusDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// [status] を [MeterCaptureScreenState] へ反映する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute(const MeterInAppCameraUiReady(aspectRatio: 1));
  /// ```
  Future<void> execute(MeterInAppCameraUiStatus status) async {
    await state.updateWithLock((current, emitter) async {
      final next = switch (status) {
        MeterInAppCameraUiIdle() => current.copyWith(
          cameraUi: MeterCaptureCameraUi.idle,
        ),
        MeterInAppCameraUiStarting() => current.copyWith(
          cameraUi: MeterCaptureCameraUi.starting,
          clearPermissionDeniedKind:
              current.permissionDeniedKind == MeterPhotoPermissionKind.camera,
        ),
        MeterInAppCameraUiReady(:final aspectRatio) => current.copyWith(
          cameraUi: MeterCaptureCameraUi.ready,
          previewAspectRatio: aspectRatio,
          clearPermissionDeniedKind:
              current.permissionDeniedKind == MeterPhotoPermissionKind.camera,
          captureError: false,
        ),
        MeterInAppCameraUiPermissionDenied() => current.copyWith(
          cameraUi: MeterCaptureCameraUi.permissionDenied,
          permissionDeniedKind: MeterPhotoPermissionKind.camera,
        ),
        MeterInAppCameraUiFailed() => current.copyWith(
          cameraUi: MeterCaptureCameraUi.failed,
          clearPermissionDeniedKind:
              current.permissionDeniedKind == MeterPhotoPermissionKind.camera,
        ),
      };
      await emitter.emit(next);
    });
  }
}
