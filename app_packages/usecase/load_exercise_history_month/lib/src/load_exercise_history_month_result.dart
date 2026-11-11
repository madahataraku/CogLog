import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 月内の運動履歴全件。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoryMonthResult(items: []);
/// ```
final class LoadExerciseHistoryMonthResult {
  /// [items] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoryMonthResult(items: []);
  /// ```
  const LoadExerciseHistoryMonthResult({required this.items});

  /// 作成開始日時の降順の履歴。
  final List<ExerciseHistory> items;
}
