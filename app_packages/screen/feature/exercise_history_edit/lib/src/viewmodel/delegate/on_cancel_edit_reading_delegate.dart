import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

import '../state/exercise_history_edit_screen_state.dart';

/// 読み取り中止。再アップロード開始前へ復元し、遅延結果を捨てる。
///
/// Example:
/// ```dart
/// OnCancelEditReadingDelegate(state: state).execute();
/// ```
@internal
final class OnCancelEditReadingDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnCancelEditReadingDelegate(state: state);
  /// ```
  const OnCancelEditReadingDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// スナップショットがあれば復元する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      final snapshot = current.readingRestoreSnapshot;
      if (snapshot == null) {
        return;
      }
      await emitter.emit(
        current.copyWith(
          reading: false,
          photoSessionGeneration: current.photoSessionGeneration + 1,
          fieldsSyncGeneration: current.fieldsSyncGeneration + 1,
          photoPath: snapshot.photoPath,
          clearPhotoPath: snapshot.photoPath == null,
          photoBytes: snapshot.photoBytes,
          clearPhotoBytes: snapshot.photoBytes == null,
          capturedAt: snapshot.capturedAt,
          clearCapturedAt: snapshot.capturedAt == null,
          recordedAt: snapshot.recordedAt,
          clearRecordedAt: snapshot.recordedAt == null,
          recordedAtManuallySet: snapshot.recordedAtManuallySet,
          distanceKm: snapshot.distanceKm,
          clearDistanceKm: snapshot.distanceKm == null,
          duration: snapshot.duration,
          clearDuration: snapshot.duration == null,
          caloriesKcal: snapshot.caloriesKcal,
          clearCaloriesKcal: snapshot.caloriesKcal == null,
          averageSpeedKmh: snapshot.averageSpeedKmh,
          clearAverageSpeedKmh: snapshot.averageSpeedKmh == null,
          showHandEntryGuidance: snapshot.showHandEntryGuidance,
          dirty: snapshot.dirty,
          distanceInvalid: snapshot.distanceInvalid,
          durationInvalid: snapshot.durationInvalid,
          caloriesInvalid: snapshot.caloriesInvalid,
          recordedAtInvalid: snapshot.recordedAtInvalid,
          permissionDeniedKind: snapshot.permissionDeniedKind,
          clearPermissionDeniedKind: snapshot.permissionDeniedKind == null,
          clearReadingRestoreSnapshot: true,
        ),
      );
    });
  }
}
