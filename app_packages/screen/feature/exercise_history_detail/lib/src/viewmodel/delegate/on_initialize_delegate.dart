import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

import '../state/exercise_history_detail_screen_state.dart';

/// 詳細と同一日 ID 列を読み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadDetailUsecase: loadDetailUsecase,
///   loadSameDayUsecase: loadSameDayUsecase,
/// ).execute(id: 'id');
/// ```
final class OnInitializeDelegate {
  /// [state] と詳細・同一日 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   loadDetailUsecase: loadDetailUsecase,
  ///   loadSameDayUsecase: loadSameDayUsecase,
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.loadDetailUsecase,
    required this.loadSameDayUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryDetailScreenState> state;

  /// 詳細の読み込み。
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// 同一記録日 ID 列の読み込み。
  final LoadExerciseHistoriesForSameRecordedDayUsecase loadSameDayUsecase;

  /// [id] の詳細を読み、続けて同一日列を載せる。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(id: 'id');
  /// ```
  Future<void> execute({required String id}) async {
    late final int generation;
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current.loading) {
        return false;
      }
      generation = current.detailLoadGeneration + 1;
      await emitter.emit(
        ExerciseHistoryDetailScreenState.initial(id: id)
            .copyWith(loading: true, detailLoadGeneration: generation),
      );
      return true;
    });
    if (!shouldLoad) {
      return;
    }

    await loadExerciseHistoryDetail(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
      id: id,
      startedGeneration: generation,
    );

    final afterDetail = state.state;
    if (afterDetail.missing ||
        afterDetail.error != null ||
        afterDetail.detailLoadGeneration != generation) {
      return;
    }

    try {
      final same = await loadSameDayUsecase.execute(
        LoadExerciseHistoriesForSameRecordedDayRequest(id: id),
      );
      await state.updateWithLock((current, emitter) async {
        if (current.id != id || current.detailLoadGeneration != generation) {
          return;
        }
        switch (same) {
          case LoadExerciseHistoriesForSameRecordedDaySuccess(
            :final ids,
            :final initialIndex,
          ):
            await emitter.emit(
              current.copyWith(sameDayIds: ids, pageIndex: initialIndex),
            );
          case LoadExerciseHistoriesForSameRecordedDayNotFound():
            await emitter.emit(
              current.copyWith(sameDayIds: [id], pageIndex: 0),
            );
        }
      });
    } catch (_) {
      await state.updateWithLock((current, emitter) async {
        if (current.id != id || current.detailLoadGeneration != generation) {
          return;
        }
        await emitter.emit(current.copyWith(sameDayIds: [id], pageIndex: 0));
      });
    }
  }
}

/// 詳細を読み、成功・不在・失敗を State へ書く。
///
/// Example:
/// ```dart
/// loadExerciseHistoryDetail(
///   state: state,
///   loadDetailUsecase: usecase,
///   id: 'id',
///   startedGeneration: 1,
/// );
/// ```
Future<void> loadExerciseHistoryDetail({
  required MutableStateStream<ExerciseHistoryDetailScreenState> state,
  required LoadExerciseHistoryDetailUsecase loadDetailUsecase,
  required String id,
  required int startedGeneration,
}) async {
  try {
    final result = await loadDetailUsecase.execute(
      LoadExerciseHistoryDetailRequest(id: id),
    );
    try {
      await state.updateWithLock((current, emitter) async {
        if (current.id != id ||
            current.detailLoadGeneration != startedGeneration) {
          return;
        }
        switch (result) {
          case LoadExerciseHistoryDetailNotFound():
            await emitter.emit(
              current.copyWith(
                loading: false,
                missing: true,
                clearHistory: true,
                clearPhotoAbsolutePath: true,
                clearError: true,
              ),
            );
          case LoadExerciseHistoryDetailSuccess(
            :final history,
            :final photoAbsolutePath,
          ):
            await emitter.emit(
              current.copyWith(
                loading: false,
                missing: false,
                history: history,
                photoAbsolutePath: photoAbsolutePath,
                clearPhotoAbsolutePath: photoAbsolutePath == null,
                clearError: true,
              ),
            );
        }
      });
    } on StateStreamClosedException {
      return;
    }
  } catch (error) {
    try {
      await state.updateWithLock((current, emitter) async {
        if (current.id != id ||
            current.detailLoadGeneration != startedGeneration) {
          return;
        }
        await emitter.emit(
          current.copyWith(
            loading: false,
            missing: false,
            clearHistory: true,
            clearPhotoAbsolutePath: true,
            error: error,
          ),
        );
      });
    } on StateStreamClosedException {
      return;
    }
  }
}
