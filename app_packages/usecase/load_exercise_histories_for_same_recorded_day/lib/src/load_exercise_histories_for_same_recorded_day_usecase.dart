import 'package:riverpod/riverpod.dart';

import 'load_exercise_histories_for_same_recorded_day_request.dart';
import 'load_exercise_histories_for_same_recorded_day_result.dart';

/// 同一記録日（現地暦日）の運動履歴 ID 列を読み込む。
///
/// Example:
/// ```dart
/// usecase.execute(
///   const LoadExerciseHistoriesForSameRecordedDayRequest(id: 'id'),
/// );
/// ```
abstract interface class LoadExerciseHistoriesForSameRecordedDayUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider =
      Provider<LoadExerciseHistoriesForSameRecordedDayUsecase>(
        (ref) => throw UnimplementedError(
          'LoadExerciseHistoriesForSameRecordedDayUsecase.provider',
        ),
      );

  /// [request] の ID と同じ記録日の列を返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const LoadExerciseHistoriesForSameRecordedDayRequest(id: 'id'),
  /// );
  /// ```
  Future<LoadExerciseHistoriesForSameRecordedDayResult> execute(
    LoadExerciseHistoriesForSameRecordedDayRequest request,
  );
}
