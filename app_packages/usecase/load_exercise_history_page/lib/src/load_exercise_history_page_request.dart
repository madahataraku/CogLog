/// 月と頁位置を指定して一覧を読む依頼。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoryPageRequest(
///   year: 2026,
///   month: 11,
///   offset: 0,
///   limit: 30,
/// );
/// ```
final class LoadExerciseHistoryPageRequest {
  /// [year]/[month] は端末ローカル暦。[offset] は 0 起点。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoryPageRequest(
  ///   year: 2026,
  ///   month: 11,
  ///   offset: 0,
  /// );
  /// ```
  const LoadExerciseHistoryPageRequest({
    required this.year,
    required this.month,
    required this.offset,
    this.limit = 30,
  });

  /// 西暦年。
  final int year;

  /// 月（1–12）。
  final int month;

  /// 読み飛ばす件数。
  final int offset;

  /// 取得上限。既定は 30。
  final int limit;
}
