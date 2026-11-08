/// 運動履歴 ID で詳細を読む依頼。
///
/// Example:
/// ```dart
/// const LoadExerciseHistoryDetailRequest(id: '11111111-1111-4111-8111-111111111111');
/// ```
final class LoadExerciseHistoryDetailRequest {
  /// [id] を指定する。
  ///
  /// Example:
  /// ```dart
  /// const LoadExerciseHistoryDetailRequest(
  ///   id: '11111111-1111-4111-8111-111111111111',
  /// );
  /// ```
  const LoadExerciseHistoryDetailRequest({required this.id});

  /// 運動履歴 ID。
  final String id;
}
