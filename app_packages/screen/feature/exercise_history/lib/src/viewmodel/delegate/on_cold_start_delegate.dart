import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';

import '../state/exercise_history_screen_state.dart';
import 'load_exercise_history_month.dart';

/// 現地当月をセットして月全件を読む。
///
/// Example:
/// ```dart
/// OnColdStartDelegate(
///   state: state,
///   loadMonthUsecase: loadMonthUsecase,
///   now: DateTime(2026, 11, 8),
/// ).execute();
/// ```
final class OnColdStartDelegate {
  /// [state] と月 Usecase、基準時刻を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnColdStartDelegate(
  ///   state: state,
  ///   loadMonthUsecase: loadMonthUsecase,
  ///   now: DateTime(2026, 11, 8),
  /// );
  /// ```
  const OnColdStartDelegate({
    required this.state,
    required this.loadMonthUsecase,
    required this.now,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 月内全件の読み込み。
  final LoadExerciseHistoryMonthUsecase loadMonthUsecase;

  /// 当月判定に使う時刻。
  final DateTime now;

  /// 当月へ初期化し、月データを読む。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    final local = now.toLocal();
    final year = local.year;
    final month = local.month;
    late final int generation;
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current.loading) {
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
