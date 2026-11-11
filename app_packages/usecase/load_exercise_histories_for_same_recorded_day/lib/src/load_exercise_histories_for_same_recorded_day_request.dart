/// 初期表示する運動履歴 ID。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoriesForSameRecordedDayRequest(id: 'id');
/// ```
final class LoadExerciseHistoriesForSameRecordedDayRequest {
  /// [id] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoriesForSameRecordedDayRequest(id: 'id');
  /// ```
  const LoadExerciseHistoriesForSameRecordedDayRequest({required this.id});

  /// 初期表示対象の運動履歴 ID。
  final String id;
}
