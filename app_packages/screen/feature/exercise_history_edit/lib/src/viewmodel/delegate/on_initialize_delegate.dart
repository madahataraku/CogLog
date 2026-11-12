import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

import '../state/exercise_history_edit_screen_state.dart';

/// 編集対象の詳細を読み、入力の初期値にする。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadDetailUsecase: loadDetailUsecase,
/// ).execute(id: 'id');
/// ```
final class OnInitializeDelegate {
  /// [state] と詳細 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   loadDetailUsecase: loadDetailUsecase,
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.loadDetailUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// 詳細の読み込み。
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// [id] の詳細を読み、編集フィールドへ載せる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute(id: 'id');
  /// ```
  Future<void> execute({required String id}) async {
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current.loading || current.saving || current.reading) {
        return false;
      }
      await emitter.emit(
        ExerciseHistoryEditScreenState.initial(id: id).copyWith(loading: true),
      );
      return true;
    });
    if (!shouldLoad) {
      return;
    }

    try {
      final result = await loadDetailUsecase.execute(
        LoadExerciseHistoryDetailRequest(id: id),
      );
      await state.updateWithLock((current, emitter) async {
        if (current.id != id) {
          return;
        }
        switch (result) {
          case LoadExerciseHistoryDetailNotFound():
            await emitter.emit(
              current.copyWith(loading: false, missing: true, loadError: false),
            );
          case LoadExerciseHistoryDetailSuccess(
            :final history,
            :final photoAbsolutePath,
          ):
            await emitter.emit(
              _fromHistory(
                current: current,
                history: history,
                photoAbsolutePath: photoAbsolutePath,
              ),
            );
        }
      });
    } on StateStreamClosedException {
      return;
    } on Object {
      try {
        await state.updateWithLock((current, emitter) async {
          if (current.id != id) {
            return;
          }
          await emitter.emit(
            current.copyWith(loading: false, missing: false, loadError: true),
          );
        });
      } on StateStreamClosedException {
        return;
      }
    }
  }
}

ExerciseHistoryEditScreenState _fromHistory({
  required ExerciseHistoryEditScreenState current,
  required ExerciseHistory history,
  required String? photoAbsolutePath,
}) {
  return current.copyWith(
    loading: false,
    missing: false,
    loadError: false,
    dirty: false,
    saveError: false,
    inputsInvalid: false,
    showHandEntryGuidance: false,
    photoPath: photoAbsolutePath,
    clearPhotoPath: photoAbsolutePath == null,
    clearPhotoBytes: true,
    creationStartedAt: history.creationStartedAt,
    capturedAt: history.capturedAt,
    recordedAt: history.recordedAt,
    distanceKm: history.distanceKm,
    duration: history.duration,
    caloriesKcal: history.caloriesKcal,
    averageSpeedKmh: history.averageSpeedKmh,
    previousHealthWorkoutId: history.healthWorkoutId,
    clearPreviousHealthWorkoutId: history.healthWorkoutId == null,
    clearPermissionDeniedKind: true,
  );
}
