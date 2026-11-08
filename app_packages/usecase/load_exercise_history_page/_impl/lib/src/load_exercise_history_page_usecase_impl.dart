import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';

/// Repository から一覧頁を読む。
///
/// Example:
/// ```dart
/// LoadExerciseHistoryPageUsecaseImpl(histories: histories).execute(
///   const LoadExerciseHistoryPageRequest(year: 2026, month: 11, offset: 0),
/// );
/// ```
final class LoadExerciseHistoryPageUsecaseImpl
    implements LoadExerciseHistoryPageUsecase {
  /// [histories] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadExerciseHistoryPageUsecaseImpl(histories: histories);
  /// ```
  const LoadExerciseHistoryPageUsecaseImpl({required this.histories});

  /// 運動履歴の読み出し。
  final ExerciseHistoryRepository histories;

  /// [request] の月・頁で読み、件数が limit と同じなら hasMore を true にする。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const LoadExerciseHistoryPageRequest(year: 2026, month: 11, offset: 0),
  /// );
  /// ```
  @override
  Future<LoadExerciseHistoryPageResult> execute(
    LoadExerciseHistoryPageRequest request,
  ) async {
    final items = await histories.listPage(
      year: request.year,
      month: request.month,
      offset: request.offset,
      limit: request.limit,
    );
    return LoadExerciseHistoryPageResult(
      items: items,
      hasMore: items.length == request.limit,
    );
  }
}
