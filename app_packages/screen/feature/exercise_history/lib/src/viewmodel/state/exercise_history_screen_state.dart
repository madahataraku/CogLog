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
    this.pendingTutorial = false,
  });

  /// 指定月の未読込（読込中）状態。
  ///
  /// 推移画面と同様、初期は loading にして Ready 前の文脈評価を防ぐ。
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
    loading: true,
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

  /// 運動履歴文脈コーチマーク（段階8）を表示予約しているとき true。
  final bool pendingTutorial;

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
    bool? pendingTutorial,
  }) => ExerciseHistoryScreenState(
    year: year ?? this.year,
    month: month ?? this.month,
    items: items ?? this.items,
    loading: loading ?? this.loading,
    loadError: clearLoadError ? null : (loadError ?? this.loadError),
    reloadGeneration: reloadGeneration ?? this.reloadGeneration,
    pendingTutorial: pendingTutorial ?? this.pendingTutorial,
  );
}
