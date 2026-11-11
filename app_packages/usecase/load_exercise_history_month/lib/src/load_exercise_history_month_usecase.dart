import 'package:riverpod/riverpod.dart';

import 'load_exercise_history_month_request.dart';
import 'load_exercise_history_month_result.dart';

/// 運動履歴の月内全件を読み込む。
///
/// Example:
/// ```dart
/// usecase.execute(
///   const LoadExerciseHistoryMonthRequest(year: 2026, month: 11),
/// );
/// ```
abstract interface class LoadExerciseHistoryMonthUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<LoadExerciseHistoryMonthUsecase>(
    (ref) =>
        throw UnimplementedError('LoadExerciseHistoryMonthUsecase.provider'),
  );

  /// [request] の月の全件を読む。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const LoadExerciseHistoryMonthRequest(year: 2026, month: 11),
  /// );
  /// ```
  Future<LoadExerciseHistoryMonthResult> execute(
    LoadExerciseHistoryMonthRequest request,
  );
}
