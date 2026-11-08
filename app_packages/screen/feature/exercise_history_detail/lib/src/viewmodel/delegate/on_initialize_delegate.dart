import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

import '../state/exercise_history_detail_screen_state.dart';

/// 詳細を読み、State を置き換える。
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
  final MutableStateStream<ExerciseHistoryDetailScreenState> state;

  /// 詳細の読み込み。
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// [id] の詳細を読む。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(id: 'id');
  /// ```
  Future<void> execute({required String id}) async {
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current.loading) {
        return false;
      }
      await emitter.emit(
        ExerciseHistoryDetailScreenState.initial(id: id)
            .copyWith(loading: true),
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
    );
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
/// );
/// ```
Future<void> loadExerciseHistoryDetail({
  required MutableStateStream<ExerciseHistoryDetailScreenState> state,
  required LoadExerciseHistoryDetailUsecase loadDetailUsecase,
  required String id,
}) async {
  try {
    final result = await loadDetailUsecase.execute(
      LoadExerciseHistoryDetailRequest(id: id),
    );
    try {
      await state.updateWithLock((current, emitter) async {
        if (current.id != id) {
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
        if (current.id != id) {
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
