/// 運動履歴 1 件を削除する入力。
///
/// Example:
/// ```dart
/// const DeleteExerciseHistoryRequest(
///   id: '11111111-1111-4111-8111-111111111111',
///   healthWorkoutId: null,
/// );
/// ```
final class DeleteExerciseHistoryRequest {
  /// [id] と任意の [healthWorkoutId] を指定する。
  ///
  /// Example:
  /// ```dart
  /// const DeleteExerciseHistoryRequest(
  ///   id: '11111111-1111-4111-8111-111111111111',
  ///   healthWorkoutId: null,
  /// );
  /// ```
  const DeleteExerciseHistoryRequest({
    required this.id,
    required this.healthWorkoutId,
  });

  /// 削除対象の運動履歴 ID。
  final String id;

  /// 対応するヘルスワークアウト ID。null ならヘルス削除しない。
  final String? healthWorkoutId;
}
