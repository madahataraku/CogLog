import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

import '../state/exercise_history_detail_screen_state.dart';
import 'on_initialize_delegate.dart';

/// 同一日ページめくりで対象 ID を差し替え、詳細を再読込する。
///
/// Example:
/// ```dart
/// OnPageChangedDelegate(
///   state: state,
///   loadDetailUsecase: loadDetailUsecase,
/// ).execute(index: 1);
/// ```
final class OnPageChangedDelegate {
  /// [state] と詳細 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnPageChangedDelegate(
  ///   state: state,
  ///   loadDetailUsecase: loadDetailUsecase,
  /// );
  /// ```
  const OnPageChangedDelegate({
    required this.state,
    required this.loadDetailUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryDetailScreenState> state;

  /// 詳細の読み込み。
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// [index] の同一日 ID へ切り替えて詳細を読む。
  ///
  /// 失敗しても [ExerciseHistoryDetailScreenState.pageIndex] は戻さない。
  /// 開始時に [ExerciseHistoryDetailScreenState.detailLoadGeneration] を進め、
  /// 古い要求の結果は捨てる。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(index: 1);
  /// ```
  Future<void> execute({required int index}) async {
    final ids = state.state.sameDayIds;
    if (index < 0 || index >= ids.length) {
      return;
    }
    final id = ids[index];
    late final int generation;
    try {
      await state.updateWithLock((current, emitter) async {
        generation = current.detailLoadGeneration + 1;
        await emitter.emit(
          current.copyWith(
            id: id,
            pageIndex: index,
            pageLoading: true,
            clearError: true,
            detailLoadGeneration: generation,
          ),
        );
      });
    } on StateStreamClosedException {
      return;
    }

    await loadExerciseHistoryDetail(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
      id: id,
      startedGeneration: generation,
    );

    try {
      await state.updateWithLock((current, emitter) async {
        if (current.detailLoadGeneration != generation) {
          return;
        }
        await emitter.emit(current.copyWith(pageLoading: false));
      });
    } on StateStreamClosedException {
      return;
    }
  }
}
