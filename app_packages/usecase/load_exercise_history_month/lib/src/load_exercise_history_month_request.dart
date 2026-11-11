/// 月内の運動履歴全件を読むときの年月。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoryMonthRequest(year: 2026, month: 11);
/// ```
final class LoadExerciseHistoryMonthRequest {
  /// 西暦年と月（1–12）を持つ。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoryMonthRequest(year: 2026, month: 11);
  /// ```
  const LoadExerciseHistoryMonthRequest({
    required this.year,
    required this.month,
  });

  /// 西暦年。
  final int year;

  /// 月（1–12）。
  final int month;
}
