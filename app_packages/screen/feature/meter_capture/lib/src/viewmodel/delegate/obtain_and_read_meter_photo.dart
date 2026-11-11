import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/meter_capture_camera_ui.dart';
import '../state/meter_capture_screen_state.dart';
import 'on_read_meter_delegate.dart';

/// [source] から写真を取り、成功時は読み取りへ進む。
///
/// ライブラリのキャンセルでは State を変えない。カメラの null／例外は
/// [MeterCaptureScreenState.captureError] を立てる。権限拒否では種別だけ載せる。
///
/// Example:
/// ```dart
/// obtainAndReadMeterPhoto(
///   state: state,
///   obtainMeterPhotoUsecase: obtain,
///   readMeterPanelUsecase: read,
///   evaluateOnDeviceLlmGuidanceUsecase: evaluate,
///   guidanceSession: session,
///   source: ObtainMeterPhotoSource.camera,
/// );
/// ```
@internal
Future<void> obtainAndReadMeterPhoto({
  required MutableStateStream<MeterCaptureScreenState> state,
  required ObtainMeterPhotoUsecase obtainMeterPhotoUsecase,
  required ReadMeterPanelUsecase readMeterPanelUsecase,
  required EvaluateOnDeviceLlmGuidanceUsecase
  evaluateOnDeviceLlmGuidanceUsecase,
  required OnDeviceLlmGuidanceSession guidanceSession,
  required ObtainMeterPhotoSource source,
}) async {
  if (state.state.reading || state.state.saving) {
    return;
  }

  if (source == ObtainMeterPhotoSource.camera &&
      state.state.cameraUi != MeterCaptureCameraUi.ready) {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(captureError: true));
    });
    return;
  }

  final generation = state.state.cameraSessionGeneration;

  final ObtainMeterPhotoResult result;
  try {
    result = await obtainMeterPhotoUsecase.execute(
      ObtainMeterPhotoRequest(source: source),
    );
  } on Object {
    if (source == ObtainMeterPhotoSource.camera) {
      await state.updateWithLock((current, emitter) async {
        if (current.cameraSessionGeneration != generation) {
          return;
        }
        await emitter.emit(current.copyWith(captureError: true));
      });
    }
    return;
  }

  if (state.state.cameraSessionGeneration != generation) {
    return;
  }

  switch (result) {
    case ObtainMeterPhotoCancelled():
      if (source == ObtainMeterPhotoSource.camera) {
        await state.updateWithLock((current, emitter) async {
          if (current.cameraSessionGeneration != generation) {
            return;
          }
          await emitter.emit(current.copyWith(captureError: true));
        });
      }
      return;
    case ObtainMeterPhotoPermissionDenied(:final kind):
      await state.updateWithLock((current, emitter) async {
        if (current.cameraSessionGeneration != generation) {
          return;
        }
        await emitter.emit(current.copyWith(permissionDeniedKind: kind));
      });
    case ObtainMeterPhotoSuccess(:final bytes, :final capturedAt):
      final creationStartedAt = DateTime.timestamp();
      final resolvedCapturedAt = capturedAt ?? creationStartedAt;
      await state.updateWithLock((current, emitter) async {
        if (current.cameraSessionGeneration != generation) {
          return;
        }
        await emitter.emit(
          current.copyWith(
            photoBytes: bytes,
            creationStartedAt: creationStartedAt,
            capturedAt: resolvedCapturedAt,
            recordedAt: resolvedCapturedAt,
            recordedAtManuallySet: false,
            clearPermissionDeniedKind: true,
            saveError: false,
            captureError: false,
          ),
        );
      });
      if (state.state.cameraSessionGeneration != generation) {
        return;
      }
      await OnReadMeterDelegate(
        state: state,
        readMeterPanelUsecase: readMeterPanelUsecase,
        evaluateOnDeviceLlmGuidanceUsecase: evaluateOnDeviceLlmGuidanceUsecase,
        guidanceSession: guidanceSession,
      ).execute(photoBytes: bytes, expectedGeneration: generation);
  }
}
