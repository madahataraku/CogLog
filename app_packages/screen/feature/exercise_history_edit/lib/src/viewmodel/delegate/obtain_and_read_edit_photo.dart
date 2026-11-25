import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_obtain_meter_photo/usecase_obtain_meter_photo.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

import '../state/edit_reading_restore_snapshot.dart';
import '../state/exercise_history_edit_screen_state.dart';

/// [source] から写真を取り、成功時は読み取り結果を編集フィールドへ載せる。
///
/// ピッカー起動前の値を [EditReadingRestoreSnapshot] に取り、写真確定後の
/// `reading: true` と同時に State へ載せる。ピッカー取消・権限拒否では
/// スナップショットを載せない。読み取り中止は世代を進め遅延結果を捨てる。
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
  if (state.state.reading || state.state.saving || state.state.loading) {
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
      await state.updateWithLock((current, emitter) async {
        if (current.photoSessionGeneration != generation) {
          return;
        }
        final resolvedCapturedAt =
            capturedAt ?? current.creationStartedAt ?? DateTime.timestamp();
        await emitter.emit(
          current.copyWith(
            photoBytes: bytes,
            capturedAt: resolvedCapturedAt,
            recordedAt: current.recordedAtManuallySet
                ? current.recordedAt
                : resolvedCapturedAt,
            dirty: true,
            reading: true,
            readingRestoreSnapshot: restoreSnapshot,
            showHandEntryGuidance: false,
            clearPermissionDeniedKind: true,
            saveError: false,
          ),
        );
      });
      if (state.state.photoSessionGeneration != generation) {
        return;
      }

      ReadMeterPanelResult readResult;
      try {
        readResult = await readMeterPanelUsecase.execute(
          ReadMeterPanelRequest(photoBytes: bytes),
        );
      } on Object {
        readResult = const ReadMeterPanelResult(
          values: MeterReadingValues(),
          averageSpeedFromPanel: false,
        );
      }

      if (state.state.photoSessionGeneration != generation) {
        return;
      }

      final values = readResult.values;
      final speed = (values.distanceKm != null && values.duration != null)
          ? calculateAverageSpeedKmh(
              distanceKm: values.distanceKm!,
              duration: values.duration!,
            )
          : null;
      await state.updateWithLock((current, emitter) async {
        if (current.photoSessionGeneration != generation) {
          return;
        }
        await emitter.emit(
          current.copyWith(
            reading: false,
            distanceKm: values.distanceKm,
            clearDistanceKm: values.distanceKm == null,
            duration: values.duration,
            clearDuration: values.duration == null,
            caloriesKcal: values.caloriesKcal,
            clearCaloriesKcal: values.caloriesKcal == null,
            averageSpeedKmh: speed,
            clearAverageSpeedKmh: speed == null,
            showHandEntryGuidance: needsMeterHandEntryGuidance(values),
            distanceInvalid: false,
            durationInvalid: false,
            caloriesInvalid: false,
            dirty: true,
            fieldsSyncGeneration: current.fieldsSyncGeneration + 1,
            clearReadingRestoreSnapshot: true,
          ),
        );
      });
  }
}
