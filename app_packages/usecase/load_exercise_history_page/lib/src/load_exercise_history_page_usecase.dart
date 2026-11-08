import 'package:riverpod/riverpod.dart';

import 'load_exercise_history_page_request.dart';
import 'load_exercise_history_page_result.dart';

/// 運動履歴一覧の 1 頁を読み込む。
///
/// Example:
/// ```dart
/// usecase.execute(
///   const LoadExerciseHistoryPageRequest(year: 2026, month: 11, offset: 0),
/// );
/// ```
abstract interface class LoadExerciseHistoryPageUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<LoadExerciseHistoryPageUsecase>(
    (ref) => throw UnimplementedError('LoadExerciseHistoryPageUsecase.provider'),
  );

  /// [request] の月・頁で読む。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const LoadExerciseHistoryPageRequest(year: 2026, month: 11, offset: 0),
  /// );
  /// ```
  Future<LoadExerciseHistoryPageResult> execute(
    LoadExerciseHistoryPageRequest request,
  );
}
