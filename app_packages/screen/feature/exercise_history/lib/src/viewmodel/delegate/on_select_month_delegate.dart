import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';

import '../state/exercise_history_screen_state.dart';
import 'load_exercise_history_month.dart';

/// 月を差し替え、その月の全件を読み直す。
///
/// Example:
/// ```dart
/// OnSelectMonthDelegate(
///   state: state,
///   loadMonthUsecase: loadMonthUsecase,
/// ).execute(year: 2026, month: 10);
/// ```
final class OnSelectMonthDelegate {
  /// [state] と月 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectMonthDelegate(
  ///   state: state,
  ///   loadMonthUsecase: loadMonthUsecase,
  /// );
  /// ```
  const OnSelectMonthDelegate({
    required this.state,
    required this.loadMonthUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 月内全件の読み込み。
  final LoadExerciseHistoryMonthUsecase loadMonthUsecase;

  /// [year]/[month] へ切り替え、月データを読む。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(year: 2026, month: 10);
  /// ```
  Future<void> execute({required int year, required int month}) async {
    late final int generation;
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current.year == year && current.month == month && current.loading) {
        return false;
      }
      generation = current.reloadGeneration + 1;
      await emitter.emit(
        ExerciseHistoryScreenState.initial(
          year: year,
          month: month,
        ).copyWith(loading: true, reloadGeneration: generation),
      );
      return true;
    });
    if (!shouldLoad) {
      return;
    }
    await loadExerciseHistoryMonth(
      state: state,
      loadMonthUsecase: loadMonthUsecase,
      year: year,
      month: month,
      startedGeneration: generation,
    );
  }
}
