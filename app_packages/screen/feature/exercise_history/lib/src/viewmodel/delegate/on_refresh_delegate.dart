import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';

import '../state/exercise_history_screen_state.dart';
import 'on_initialize_delegate.dart';

/// 現在の月を先頭から再取得する。
///
/// Example:
/// ```dart
/// OnRefreshDelegate(
///   state: state,
///   loadPageUsecase: loadPageUsecase,
/// ).execute();
/// ```
final class OnRefreshDelegate {
  /// [state] と一覧 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRefreshDelegate(
  ///   state: state,
  ///   loadPageUsecase: loadPageUsecase,
  /// );
  /// ```
  const OnRefreshDelegate({required this.state, required this.loadPageUsecase});

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 一覧頁の読み込み。
  final LoadExerciseHistoryPageUsecase loadPageUsecase;

  /// refreshing を立てて先頭頁を読み直す。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    final prep = await state.updateWithLock((current, emitter) async {
      if (current.loading || current.refreshing) {
        return null;
      }
      final year = current.year;
      final month = current.month;
      await emitter.emit(
        current.copyWith(
          refreshing: true,
          loadingMore: false,
          clearLoadError: true,
          clearLoadMoreError: true,
        ),
      );
      return (year: year, month: month);
    });
    if (prep == null) {
      return;
    }
    await loadExerciseHistoryFirstPage(
      state: state,
      loadPageUsecase: loadPageUsecase,
      year: prep.year,
      month: prep.month,
    );
  }
}
