import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 運動履歴カレンダーが持つ月・履歴・読込フラグ。
///
/// Example:
/// ```dart
/// ExerciseHistoryScreenState.initial(year: 2026, month: 11);
/// ```
final class ExerciseHistoryScreenState {
  /// 月と履歴と読込状態を持つ。
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
    required this.loadError,
    required this.reloadGeneration,
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
    loadError: null,
    reloadGeneration: 0,
  );

  /// 選んでいる西暦年。
  final int year;

  /// 選んでいる月（1–12）。
  final int month;

  /// 読み済みの運動履歴。
  final List<ExerciseHistory> items;

  /// 月データの読込中。
  final bool loading;

  /// 月データの読込失敗。
  final Object? loadError;

  /// 競合する再取得を捨てるための世代。
  final int reloadGeneration;

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
    Object? loadError,
    bool clearLoadError = false,
    int? reloadGeneration,
  }) => ExerciseHistoryScreenState(
    year: year ?? this.year,
    month: month ?? this.month,
    items: items ?? this.items,
    loading: loading ?? this.loading,
    loadError: clearLoadError ? null : (loadError ?? this.loadError),
    reloadGeneration: reloadGeneration ?? this.reloadGeneration,
  );
}
