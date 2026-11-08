import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';

import '../state/exercise_history_screen_state.dart';
import 'on_initialize_delegate.dart';
import 'on_load_more_delegate.dart';

/// 初回失敗または追加失敗を再試行する。
///
/// Example:
/// ```dart
/// OnRetryDelegate(
///   state: state,
///   loadPageUsecase: loadPageUsecase,
/// ).execute();
/// ```
final class OnRetryDelegate {
  /// [state] と一覧 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRetryDelegate(
  ///   state: state,
  ///   loadPageUsecase: loadPageUsecase,
  /// );
  /// ```
  const OnRetryDelegate({required this.state, required this.loadPageUsecase});

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 一覧頁の読み込み。
  final LoadExerciseHistoryPageUsecase loadPageUsecase;

  /// 初回エラーなら先頭から、追加エラーなら loadMore を再実行する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    final current = state.state;
    if (current.loadError != null) {
      final prep = await state.updateWithLock((locked, emitter) async {
        if (locked.loadError == null || locked.loading || locked.refreshing) {
          return null;
        }
        final year = locked.year;
        final month = locked.month;
        await emitter.emit(
          locked.copyWith(
            loading: true,
            items: const [],
            hasMore: true,
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
      return;
    }
    if (current.loadMoreError != null) {
      await OnLoadMoreDelegate(
        state: state,
        loadPageUsecase: loadPageUsecase,
      ).execute();
    }
  }
}
