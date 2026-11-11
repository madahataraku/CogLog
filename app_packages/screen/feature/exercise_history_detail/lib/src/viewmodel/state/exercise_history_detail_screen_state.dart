import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 運動履歴詳細が持つ読込結果と同一日ページ位置。
///
/// Example:
/// ```dart
/// ExerciseHistoryDetailScreenState.initial(id: 'id');
/// ```
final class ExerciseHistoryDetailScreenState {
  /// ID・同一日列・読込結果を持つ。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryDetailScreenState.initial(id: 'id');
  /// ```
  const ExerciseHistoryDetailScreenState({
    required this.id,
    required this.sameDayIds,
    required this.pageIndex,
    required this.pageLoading,
    required this.detailLoadGeneration,
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
        sameDayIds: const [],
        pageIndex: 0,
        pageLoading: false,
        detailLoadGeneration: 0,
        loading: false,
        history: null,
        photoAbsolutePath: null,
        missing: false,
        error: null,
      );

  /// 対象の運動履歴 ID。
  final String id;

  /// 同一記録日の ID 列（作成開始日時降順）。
  final List<String> sameDayIds;

  /// [sameDayIds] 内の表示位置。
  final int pageIndex;

  /// ページめくり後の詳細読込中。
  final bool pageLoading;

  /// 詳細読込の世代。古い非同期結果を捨てる。
  final int detailLoadGeneration;

  /// 初回などの詳細読込中か。
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
    List<String>? sameDayIds,
    int? pageIndex,
    bool? pageLoading,
    int? detailLoadGeneration,
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
    sameDayIds: sameDayIds ?? this.sameDayIds,
    pageIndex: pageIndex ?? this.pageIndex,
    pageLoading: pageLoading ?? this.pageLoading,
    detailLoadGeneration: detailLoadGeneration ?? this.detailLoadGeneration,
    loading: loading ?? this.loading,
    history: clearHistory ? null : (history ?? this.history),
    photoAbsolutePath: clearPhotoAbsolutePath
        ? null
        : (photoAbsolutePath ?? this.photoAbsolutePath),
    missing: missing ?? this.missing,
    error: clearError ? null : (error ?? this.error),
  );
}
