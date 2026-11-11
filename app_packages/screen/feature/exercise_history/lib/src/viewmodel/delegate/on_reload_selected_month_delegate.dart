import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';

import '../state/exercise_history_screen_state.dart';
import 'load_exercise_history_month.dart';

/// 選択中の月を年月そのまま再取得する。
///
/// Example:
/// ```dart
/// OnReloadSelectedMonthDelegate(
///   state: state,
///   loadMonthUsecase: loadMonthUsecase,
/// ).execute();
/// ```
final class OnReloadSelectedMonthDelegate {
  /// [state] と月 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnReloadSelectedMonthDelegate(
  ///   state: state,
  ///   loadMonthUsecase: loadMonthUsecase,
  /// );
  /// ```
  const OnReloadSelectedMonthDelegate({
    required this.state,
    required this.loadMonthUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 月内全件の読み込み。
  final LoadExerciseHistoryMonthUsecase loadMonthUsecase;

  /// 選択月を loading にして読み直す。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    late final int year;
    late final int month;
    late final int generation;
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current.loading) {
        return false;
      }
      year = current.year;
      month = current.month;
      generation = current.reloadGeneration + 1;
      await emitter.emit(
        current.copyWith(
          loading: true,
          reloadGeneration: generation,
          clearLoadError: true,
        ),
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
