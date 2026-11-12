import 'package:riverpod/riverpod.dart';

import 'update_exercise_history_request.dart';
import 'update_exercise_history_result.dart';

/// 永続済みの運動履歴 1 件を更新する。
///
/// Example:
/// ```dart
/// usecase.execute(
///   UpdateExerciseHistoryRequest(
///     id: '11111111-1111-4111-8111-111111111111',
///     creationStartedAt: DateTime.timestamp(),
///     capturedAt: DateTime.timestamp(),
///     recordedAt: DateTime.timestamp(),
///     distanceKm: 1,
///     duration: const Duration(minutes: 1),
///     caloriesKcal: 1,
///     previousHealthWorkoutId: null,
///   ),
/// );
/// ```
abstract interface class UpdateExerciseHistoryUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<UpdateExerciseHistoryUsecase>(
    (ref) => throw UnimplementedError('UpdateExerciseHistoryUsecase.provider'),
  );

  /// [request] を検証し、運動履歴を更新し、必要ならヘルスを更新する。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   UpdateExerciseHistoryRequest(
  ///     id: '11111111-1111-4111-8111-111111111111',
  ///     creationStartedAt: DateTime.timestamp(),
  ///     capturedAt: DateTime.timestamp(),
  ///     recordedAt: DateTime.timestamp(),
  ///     distanceKm: 1,
  ///     duration: const Duration(minutes: 1),
  ///     caloriesKcal: 1,
  ///     previousHealthWorkoutId: null,
  ///   ),
  /// );
  /// ```
  Future<UpdateExerciseHistoryResult> execute(
    UpdateExerciseHistoryRequest request,
  );
}
