import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';

import '../state/edit_reading_restore_snapshot.dart';
import '../state/exercise_history_edit_screen_state.dart';

/// 確定した写真バイトを載せ、パネル読み取り結果を編集フィールドへ写す。
///
/// [generation] が現在と違えば何もしない。[restoreSnapshot] は読み取り中止用に
/// `reading: true` と同時に載せる。
///
/// Example:
/// ```dart
/// applyCapturedEditPhoto(
///   state: state,
///   readMeterPanelUsecase: read,
///   bytes: bytes,
///   capturedAt: DateTime(2026, 5, 2),
///   restoreSnapshot: snapshot,
///   generation: 1,
/// );
/// ```
@internal
Future<void> applyCapturedEditPhoto({
  required MutableStateStream<ExerciseHistoryEditScreenState> state,
  required ReadMeterPanelUsecase readMeterPanelUsecase,
  required Uint8List bytes,
  required DateTime? capturedAt,
  required EditReadingRestoreSnapshot restoreSnapshot,
  required int generation,
}) async {
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
