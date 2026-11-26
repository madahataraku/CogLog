import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

import '../state/edit_reading_restore_snapshot.dart';
import '../state/exercise_history_edit_phase.dart';
import '../state/exercise_history_edit_screen_state.dart';
import 'apply_captured_edit_photo.dart';

/// [source] から写真を取り、成功時は読み取り結果を編集フィールドへ載せる。
///
/// ピッカー起動前の値を [EditReadingRestoreSnapshot] に取り、写真確定後の
/// `reading: true` と同時に State へ載せる。ピッカー取消・権限拒否では
/// スナップショットを載せない。読み取り中止は世代を進め遅延結果を捨てる。
/// アプリ内カメラ phase 中は呼ばない（シャッターは [applyCapturedEditPhoto]）。
///
/// Example:
/// ```dart
/// obtainAndReadEditPhoto(
///   state: state,
///   obtainMeterPhotoUsecase: obtain,
///   readMeterPanelUsecase: read,
///   source: ObtainMeterPhotoSource.library,
/// );
/// ```
@internal
Future<void> obtainAndReadEditPhoto({
  required MutableStateStream<ExerciseHistoryEditScreenState> state,
  required ObtainMeterPhotoUsecase obtainMeterPhotoUsecase,
  required ReadMeterPanelUsecase readMeterPanelUsecase,
  required ObtainMeterPhotoSource source,
}) async {
  if (state.state.reading ||
      state.state.saving ||
      state.state.loading ||
      state.state.phase == ExerciseHistoryEditPhase.camera) {
    return;
  }

  final restoreSnapshot = EditReadingRestoreSnapshot.from(state.state);

  late final int generation;
  await state.updateWithLock((current, emitter) async {
    generation = current.photoSessionGeneration + 1;
    await emitter.emit(
      current.copyWith(
        photoSessionGeneration: generation,
        clearPermissionDeniedKind: true,
        saveError: false,
      ),
    );
  });

  final ObtainMeterPhotoResult result;
  try {
    result = await obtainMeterPhotoUsecase.execute(
      ObtainMeterPhotoRequest(source: source),
    );
  } on Object {
    return;
  }

  if (state.state.photoSessionGeneration != generation) {
    return;
  }

  switch (result) {
    case ObtainMeterPhotoCancelled():
      return;
    case ObtainMeterPhotoPermissionDenied(:final kind):
      await state.updateWithLock((current, emitter) async {
        if (current.photoSessionGeneration != generation) {
          return;
        }
        await emitter.emit(current.copyWith(permissionDeniedKind: kind));
      });
    case ObtainMeterPhotoSuccess(:final bytes, :final capturedAt):
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
