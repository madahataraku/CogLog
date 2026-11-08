import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 一覧 1 頁の結果。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoryPageResult(items: [], hasMore: false);
/// ```
final class LoadExerciseHistoryPageResult {
  /// [items] と続きの有無を持つ。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoryPageResult(items: [], hasMore: false);
  /// ```
  const LoadExerciseHistoryPageResult({
    required this.items,
    required this.hasMore,
  });

  /// 取得した運動履歴。
  final List<ExerciseHistory> items;

  /// 同じ条件で次頁があり得るか（今回の件数が limit と同じとき true）。
  final bool hasMore;
}
