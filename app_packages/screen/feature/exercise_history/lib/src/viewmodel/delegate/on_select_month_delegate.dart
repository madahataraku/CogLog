import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';

import '../state/exercise_history_screen_state.dart';
import 'on_initialize_delegate.dart';

/// 月を差し替え、リストを先頭から読み直す。
///
/// Example:
/// ```dart
/// OnSelectMonthDelegate(
///   state: state,
///   loadPageUsecase: loadPageUsecase,
/// ).execute(year: 2026, month: 10);
/// ```
final class OnSelectMonthDelegate {
  /// [state] と一覧 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectMonthDelegate(
  ///   state: state,
  ///   loadPageUsecase: loadPageUsecase,
  /// );
  /// ```
  const OnSelectMonthDelegate({
    required this.state,
    required this.loadPageUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 一覧頁の読み込み。
  final LoadExerciseHistoryPageUsecase loadPageUsecase;

  /// [year]/[month] へ切り替え、先頭頁を読む。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(year: 2026, month: 10);
  /// ```
  Future<void> execute({required int year, required int month}) async {
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current.year == year &&
          current.month == month &&
          (current.loading || current.refreshing)) {
        return false;
      }
      await emitter.emit(
        ExerciseHistoryScreenState.initial(
          year: year,
          month: month,
        ).copyWith(loading: true),
      );
      return true;
    });
    if (!shouldLoad) {
      return;
    }
    await loadExerciseHistoryFirstPage(
      state: state,
      loadPageUsecase: loadPageUsecase,
      year: year,
      month: month,
    );
  }
}
