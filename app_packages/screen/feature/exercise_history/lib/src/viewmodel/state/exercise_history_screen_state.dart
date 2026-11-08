import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 運動履歴一覧が持つ月・頁・読込フラグ。
///
/// Example:
/// ```dart
/// ExerciseHistoryScreenState.initial(year: 2026, month: 11);
/// ```
final class ExerciseHistoryScreenState {
  /// 月とリストと読込状態を持つ。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryScreenState.initial(year: 2026, month: 11);
  /// ```
  const ExerciseHistoryScreenState({
    required this.year,
    required this.month,
    required this.items,
    required this.loading,
    required this.refreshing,
    required this.loadingMore,
    required this.hasMore,
    required this.loadError,
    required this.loadMoreError,
  });

  /// 指定月の未読込状態。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryScreenState.initial(year: 2026, month: 11);
  /// ```
  factory ExerciseHistoryScreenState.initial({
    required int year,
    required int month,
  }) => ExerciseHistoryScreenState(
    year: year,
    month: month,
    items: const [],
    loading: false,
    refreshing: false,
    loadingMore: false,
    hasMore: true,
    loadError: null,
    loadMoreError: null,
  );

  /// 選んでいる西暦年。
  final int year;

  /// 選んでいる月（1–12）。
  final int month;

  /// 読み済みの運動履歴。
  final List<ExerciseHistory> items;

  /// 初回または月切替の読込中。
  final bool loading;

  /// Pull to refresh 中。
  final bool refreshing;

  /// 末尾追加読込中。
  final bool loadingMore;

  /// 同じ月で続きがあり得るか。
  final bool hasMore;

  /// 初回／月切替の失敗。
  final Object? loadError;

  /// 追加読込の失敗。
  final Object? loadMoreError;

  /// 一部だけ差し替えた新しい状態を返す。
  ///
  /// Example:
  /// ```dart
  /// state.copyWith(loading: true, clearLoadError: true);
  /// ```
  ExerciseHistoryScreenState copyWith({
    int? year,
    int? month,
    List<ExerciseHistory>? items,
    bool? loading,
    bool? refreshing,
    bool? loadingMore,
    bool? hasMore,
    Object? loadError,
    bool clearLoadError = false,
    Object? loadMoreError,
    bool clearLoadMoreError = false,
  }) => ExerciseHistoryScreenState(
    year: year ?? this.year,
    month: month ?? this.month,
    items: items ?? this.items,
    loading: loading ?? this.loading,
    refreshing: refreshing ?? this.refreshing,
    loadingMore: loadingMore ?? this.loadingMore,
    hasMore: hasMore ?? this.hasMore,
    loadError: clearLoadError ? null : (loadError ?? this.loadError),
    loadMoreError: clearLoadMoreError
        ? null
        : (loadMoreError ?? this.loadMoreError),
  );
}
