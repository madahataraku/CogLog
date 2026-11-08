import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';

import '../state/exercise_history_screen_state.dart';

/// 続きの頁を読み、リストへ追記する。
///
/// Example:
/// ```dart
/// OnLoadMoreDelegate(
///   state: state,
///   loadPageUsecase: loadPageUsecase,
/// ).execute();
/// ```
final class OnLoadMoreDelegate {
  /// [state] と一覧 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnLoadMoreDelegate(
  ///   state: state,
  ///   loadPageUsecase: loadPageUsecase,
  /// );
  /// ```
  const OnLoadMoreDelegate({
    required this.state,
    required this.loadPageUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 一覧頁の読み込み。
  final LoadExerciseHistoryPageUsecase loadPageUsecase;

  /// 続きがあれば次頁を読み、無ければ何もしない。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    final prep = await state.updateWithLock((current, emitter) async {
      if (!current.hasMore ||
          current.loading ||
          current.refreshing ||
          current.loadingMore ||
          current.loadError != null) {
        return null;
      }
      final year = current.year;
      final month = current.month;
      final offset = current.items.length;
      await emitter.emit(
        current.copyWith(loadingMore: true, clearLoadMoreError: true),
      );
      return (year: year, month: month, offset: offset);
    });
    if (prep == null) {
      return;
    }
    try {
      final result = await loadPageUsecase.execute(
        LoadExerciseHistoryPageRequest(
          year: prep.year,
          month: prep.month,
          offset: prep.offset,
        ),
      );
      try {
        await state.updateWithLock((current, emitter) async {
          if (current.year != prep.year || current.month != prep.month) {
            return;
          }
          if (current.items.length != prep.offset) {
            await emitter.emit(current.copyWith(loadingMore: false));
            return;
          }
          await emitter.emit(
            current.copyWith(
              items: [...current.items, ...result.items],
              hasMore: result.hasMore,
              loadingMore: false,
              clearLoadMoreError: true,
            ),
          );
        });
      } on StateStreamClosedException {
        return;
      }
    } catch (error) {
      try {
        await state.updateWithLock((current, emitter) async {
          if (current.year != prep.year || current.month != prep.month) {
            return;
          }
          if (current.items.length != prep.offset) {
            await emitter.emit(current.copyWith(loadingMore: false));
            return;
          }
          await emitter.emit(
            current.copyWith(loadingMore: false, loadMoreError: error),
          );
        });
      } on StateStreamClosedException {
        return;
      }
    }
  }
}
