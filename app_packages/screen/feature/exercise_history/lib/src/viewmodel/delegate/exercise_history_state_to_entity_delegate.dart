import '../../strings.dart';
import '../entity/exercise_history_day_cell_entity.dart';
import '../entity/exercise_history_screen_entity.dart';
import '../state/exercise_history_screen_state.dart';

/// カレンダー State を表示用 Entity へ変える。
///
/// Example:
/// ```dart
/// const ExerciseHistoryStateToEntityDelegate().execute(
///   ExerciseHistoryScreenState.initial(year: 2026, month: 11),
/// );
/// ```
final class ExerciseHistoryStateToEntityDelegate {
  /// 変換を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryStateToEntityDelegate();
  /// ```
  const ExerciseHistoryStateToEntityDelegate();

  /// [state] の月・履歴・フラグを曜日付きカレンダー Entity にする。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryStateToEntityDelegate().execute(
  ///   ExerciseHistoryScreenState.initial(year: 2026, month: 11),
  /// );
  /// ```
  ExerciseHistoryScreenEntity execute(ExerciseHistoryScreenState state) {
    final hasError = state.loadError != null;
    final showLoading = state.loading && !hasError;
    final showError = hasError && !state.loading;
    final counts = <int, int>{};
    for (final h in state.items) {
      final l = h.recordedAt.toLocal();
      if (l.year == state.year && l.month == state.month) {
        counts[l.day] = (counts[l.day] ?? 0) + 1;
      }
    }
    final leading = (DateTime(state.year, state.month, 1).weekday + 6) % 7;
    final daysInMonth = DateTime(state.year, state.month + 1, 0).day;
    final cells = <ExerciseHistoryDayCellEntity>[
      for (var i = 0; i < leading; i++)
        const ExerciseHistoryDayCellEntity(
          day: null,
          stampCount: 0,
          isTappable: false,
          semanticsLabel: '',
        ),
      for (var day = 1; day <= daysInMonth; day++)
        _dayCell(day: day, stampCount: counts[day] ?? 0),
    ];
    while (cells.length % 7 != 0) {
      cells.add(
        const ExerciseHistoryDayCellEntity(
          day: null,
          stampCount: 0,
          isTappable: false,
          semanticsLabel: '',
        ),
      );
    }
    return ExerciseHistoryScreenEntity(
      monthLabel: strings.screen_feature_exercise_history_month_label(
        year: '${state.year}',
        month: '${state.month}',
      ),
      weekdayLabels: [
        strings.screen_feature_exercise_history_weekday_mon,
        strings.screen_feature_exercise_history_weekday_tue,
        strings.screen_feature_exercise_history_weekday_wed,
        strings.screen_feature_exercise_history_weekday_thu,
        strings.screen_feature_exercise_history_weekday_fri,
        strings.screen_feature_exercise_history_weekday_sat,
        strings.screen_feature_exercise_history_weekday_sun,
      ],
      dayCells: cells,
      showLoading: showLoading,
      showError: showError,
      errorText: showError
          ? strings.screen_feature_exercise_history_error
          : null,
      canRetry: showError,
    );
  }

  /// 1 日分のセルを件数から組み立てる。
  ///
  /// Example:
  /// ```dart
  /// _dayCell(day: 5, stampCount: 2);
  /// ```
  ExerciseHistoryDayCellEntity _dayCell({
    required int day,
    required int stampCount,
  }) => ExerciseHistoryDayCellEntity(
    day: day,
    stampCount: stampCount,
    isTappable: stampCount > 0,
    semanticsLabel: stampCount == 0
        ? '$day'
        : stampCount == 1
        ? strings.screen_feature_exercise_history_stamp_semantics_one(
            day: '$day',
          )
        : strings.screen_feature_exercise_history_stamp_semantics_other(
            day: '$day',
            count: '$stampCount',
          ),
  );
}
