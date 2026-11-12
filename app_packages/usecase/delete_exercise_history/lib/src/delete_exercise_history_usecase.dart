import 'package:riverpod/riverpod.dart';

import 'delete_exercise_history_request.dart';
import 'delete_exercise_history_result.dart';

/// 永続済みの運動履歴 1 件を削除する。
///
/// Example:
/// ```dart
/// usecase.execute(
///   const DeleteExerciseHistoryRequest(
///     id: '11111111-1111-4111-8111-111111111111',
///     healthWorkoutId: null,
///   ),
/// );
/// ```
abstract interface class DeleteExerciseHistoryUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<DeleteExerciseHistoryUsecase>(
    (ref) => throw UnimplementedError('DeleteExerciseHistoryUsecase.provider'),
  );

  /// [request] の履歴を消し、必要ならヘルスも消す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const DeleteExerciseHistoryRequest(
  ///     id: '11111111-1111-4111-8111-111111111111',
  ///     healthWorkoutId: null,
  ///   ),
  /// );
  /// ```
  Future<DeleteExerciseHistoryResult> execute(
    DeleteExerciseHistoryRequest request,
  );
}
