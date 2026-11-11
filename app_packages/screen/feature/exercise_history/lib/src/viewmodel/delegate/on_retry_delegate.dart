import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';

import '../state/exercise_history_screen_state.dart';
import 'on_reload_selected_month_delegate.dart';

/// 失敗した月読込を再試行する。
///
/// Example:
/// ```dart
/// OnRetryDelegate(
///   state: state,
///   loadMonthUsecase: loadMonthUsecase,
/// ).execute();
/// ```
final class OnRetryDelegate {
  /// [state] と月 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRetryDelegate(
  ///   state: state,
  ///   loadMonthUsecase: loadMonthUsecase,
  /// );
  /// ```
  const OnRetryDelegate({required this.state, required this.loadMonthUsecase});

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 月内全件の読み込み。
  final LoadExerciseHistoryMonthUsecase loadMonthUsecase;

  /// 選択月の再取得と同じ経路で読み直す。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() => OnReloadSelectedMonthDelegate(
    state: state,
    loadMonthUsecase: loadMonthUsecase,
  ).execute();
}
