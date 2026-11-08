import 'package:domain_exercise_history/domain_exercise_history.dart';

import '../../strings.dart';
import '../entity/exercise_history_list_item_entity.dart';
import '../entity/exercise_history_screen_entity.dart';
import '../state/exercise_history_screen_state.dart';

/// 一覧 State を表示用 Entity へ変える。
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

  /// [state] の月・リスト・フラグを文言付き Entity にする。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryStateToEntityDelegate().execute(
  ///   ExerciseHistoryScreenState.initial(year: 2026, month: 11),
  /// );
  /// ```
  ExerciseHistoryScreenEntity execute(ExerciseHistoryScreenState state) {
    final hasError = state.loadError != null;
    final showLoading = state.loading && state.items.isEmpty && !hasError;
    final showEmpty =
        !state.loading && !hasError && state.items.isEmpty && !state.refreshing;
    return ExerciseHistoryScreenEntity(
      monthLabel: strings.screen_feature_exercise_history_month_label(
        year: '${state.year}',
        month: '${state.month}',
      ),
      items: [for (final item in state.items) _item(item)],
      showEmpty: showEmpty,
      showLoading: showLoading,
      showLoadMoreSpinner: state.loadingMore,
      errorText: hasError
          ? strings.screen_feature_exercise_history_error
          : null,
      loadMoreErrorText: state.loadMoreError == null
          ? null
          : strings.screen_feature_exercise_history_load_more_error,
      canRetry: hasError,
      canRetryLoadMore: state.loadMoreError != null,
    );
  }

  /// 1 件を表示用へ整形する。
  ///
  /// Example:
  /// ```dart
  /// _item(history);
  /// ```
  ExerciseHistoryListItemEntity _item(ExerciseHistory history) =>
      ExerciseHistoryListItemEntity(
        id: history.id,
        caloriesText: PeriodTotalText.oneDecimal(history.caloriesKcal),
        durationText: PeriodTotalText.duration(history.duration),
        distanceText: PeriodTotalText.oneDecimal(history.distanceKm),
        createdAtText: formatLocalDateTime(history.creationStartedAt),
      );
}

/// 端末ローカルの `yyyy-MM-dd HH:mm` にする。
///
/// Example:
/// ```dart
/// formatLocalDateTime(DateTime.utc(2026, 11, 5, 3));
/// ```
String formatLocalDateTime(DateTime value) {
  final local = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} '
      '${two(local.hour)}:${two(local.minute)}';
}
