import 'package:riverpod/riverpod.dart';

import 'load_exercise_history_detail_request.dart';
import 'load_exercise_history_detail_result.dart';

/// 運動履歴詳細を読み込む。
///
/// Example:
/// ```dart
/// usecase.execute(
///   const LoadExerciseHistoryDetailRequest(
///     id: '11111111-1111-4111-8111-111111111111',
///   ),
/// );
/// ```
abstract interface class LoadExerciseHistoryDetailUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<LoadExerciseHistoryDetailUsecase>(
    (ref) =>
        throw UnimplementedError('LoadExerciseHistoryDetailUsecase.provider'),
  );

  /// [request] の ID で読む。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const LoadExerciseHistoryDetailRequest(
  ///     id: '11111111-1111-4111-8111-111111111111',
  ///   ),
  /// );
  /// ```
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  );
}
