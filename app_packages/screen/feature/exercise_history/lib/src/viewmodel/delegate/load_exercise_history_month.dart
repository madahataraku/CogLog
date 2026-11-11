import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';

import '../state/exercise_history_screen_state.dart';

/// 指定月の全件を読み、成功または失敗を State へ書く。
///
/// [startedGeneration] と年月が現在と一致しない結果は捨てる。
///
/// Example:
/// ```dart
/// loadExerciseHistoryMonth(
///   state: state,
///   loadMonthUsecase: usecase,
///   year: 2026,
///   month: 11,
///   startedGeneration: 1,
/// );
/// ```
Future<void> loadExerciseHistoryMonth({
  required MutableStateStream<ExerciseHistoryScreenState> state,
  required LoadExerciseHistoryMonthUsecase loadMonthUsecase,
  required int year,
  required int month,
  required int startedGeneration,
}) async {
  try {
    final result = await loadMonthUsecase.execute(
      LoadExerciseHistoryMonthRequest(year: year, month: month),
    );
    await state.updateWithLock((current, emitter) async {
      if (current.year != year ||
          current.month != month ||
          current.reloadGeneration != startedGeneration) {
        return;
      }
      await emitter.emit(
        current.copyWith(
          items: result.items,
          loading: false,
          clearLoadError: true,
        ),
      );
    });
  } catch (error) {
    await state.updateWithLock((current, emitter) async {
      if (current.year != year ||
          current.month != month ||
          current.reloadGeneration != startedGeneration) {
        return;
      }
      await emitter.emit(current.copyWith(loading: false, loadError: error));
    });
  }
}
