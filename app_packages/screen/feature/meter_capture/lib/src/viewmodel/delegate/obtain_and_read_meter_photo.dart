import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

import '../state/meter_capture_screen_state.dart';
import 'on_read_meter_delegate.dart';

/// [source] から写真を取り、成功時は読み取りへ進む。
///
/// キャンセルでは State を変えない。権限拒否では種別だけ載せる。
///
/// Example:
/// ```dart
/// obtainAndReadMeterPhoto(
///   state: state,
///   obtainMeterPhotoUsecase: obtain,
///   readMeterPanelUsecase: read,
///   source: ObtainMeterPhotoSource.camera,
/// );
/// ```
@internal
Future<void> obtainAndReadMeterPhoto({
  required MutableStateStream<MeterCaptureScreenState> state,
  required ObtainMeterPhotoUsecase obtainMeterPhotoUsecase,
  required ReadMeterPanelUsecase readMeterPanelUsecase,
  required ObtainMeterPhotoSource source,
}) async {
  if (state.state.reading || state.state.saving) {
    return;
  }

  final ObtainMeterPhotoResult result;
  try {
    result = await obtainMeterPhotoUsecase.execute(
      ObtainMeterPhotoRequest(source: source),
    );
  } on Object {
    return;
  }

  switch (result) {
    case ObtainMeterPhotoCancelled():
      return;
    case ObtainMeterPhotoPermissionDenied(:final kind):
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(current.copyWith(permissionDeniedKind: kind));
      });
    case ObtainMeterPhotoSuccess(:final bytes, :final capturedAt):
      final creationStartedAt = DateTime.timestamp();
      final resolvedCapturedAt = capturedAt ?? creationStartedAt;
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(
            photoBytes: bytes,
            creationStartedAt: creationStartedAt,
            capturedAt: resolvedCapturedAt,
            recordedAt: resolvedCapturedAt,
            recordedAtManuallySet: false,
            clearPermissionDeniedKind: true,
            saveError: false,
          ),
        );
      });
      await OnReadMeterDelegate(
        state: state,
        readMeterPanelUsecase: readMeterPanelUsecase,
      ).execute(photoBytes: bytes);
  }
}
