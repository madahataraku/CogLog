import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 運動履歴詳細が持つ読込結果。
///
/// Example:
/// ```dart
/// ExerciseHistoryDetailScreenState.initial(id: 'id');
/// ```
final class ExerciseHistoryDetailScreenState {
  /// ID と読込結果を持つ。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryDetailScreenState.initial(id: 'id');
  /// ```
  const ExerciseHistoryDetailScreenState({
    required this.id,
    required this.loading,
    required this.history,
    required this.photoAbsolutePath,
    required this.missing,
    required this.error,
  });

  /// まだ読んでいない状態。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryDetailScreenState.initial(id: 'id');
  /// ```
  factory ExerciseHistoryDetailScreenState.initial({required String id}) =>
      ExerciseHistoryDetailScreenState(
        id: id,
        loading: false,
        history: null,
        photoAbsolutePath: null,
        missing: false,
        error: null,
      );

  /// 対象の運動履歴 ID。
  final String id;

  /// 読込中か。
  final bool loading;

  /// 成功時の運動履歴。
  final ExerciseHistory? history;

  /// 写真の絶対パス。無ければ null。
  final String? photoAbsolutePath;

  /// 対象が無いとき true。
  final bool missing;

  /// 読込失敗。
  final Object? error;

  /// 一部だけ差し替えた新しい状態を返す。
  ///
  /// Example:
  /// ```dart
  /// state.copyWith(loading: true, clearError: true);
  /// ```
  ExerciseHistoryDetailScreenState copyWith({
    String? id,
    bool? loading,
    ExerciseHistory? history,
    bool clearHistory = false,
    String? photoAbsolutePath,
    bool clearPhotoAbsolutePath = false,
    bool? missing,
    Object? error,
    bool clearError = false,
  }) => ExerciseHistoryDetailScreenState(
    id: id ?? this.id,
    loading: loading ?? this.loading,
    history: clearHistory ? null : (history ?? this.history),
    photoAbsolutePath: clearPhotoAbsolutePath
        ? null
        : (photoAbsolutePath ?? this.photoAbsolutePath),
    missing: missing ?? this.missing,
    error: clearError ? null : (error ?? this.error),
  );
}
