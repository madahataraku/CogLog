import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';

/// Repository から月内全件を読む。
///
/// Example:
/// ```dart
/// LoadExerciseHistoryMonthUsecaseImpl(histories: histories).execute(
///   const LoadExerciseHistoryMonthRequest(year: 2026, month: 11),
/// );
/// ```
final class LoadExerciseHistoryMonthUsecaseImpl
    implements LoadExerciseHistoryMonthUsecase {
  /// [histories] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// LoadExerciseHistoryMonthUsecaseImpl(histories: histories);
  /// ```
  const LoadExerciseHistoryMonthUsecaseImpl({required this.histories});

  /// 運動履歴の読み出し口。
  final ExerciseHistoryRepository histories;

  /// [request] の月を [ExerciseHistoryRepository.listByMonth] で読む。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const LoadExerciseHistoryMonthRequest(year: 2026, month: 11),
  /// );
  /// ```
  @override
  Future<LoadExerciseHistoryMonthResult> execute(
    LoadExerciseHistoryMonthRequest request,
  ) async {
    final items = await histories.listByMonth(
      year: request.year,
      month: request.month,
    );
    return LoadExerciseHistoryMonthResult(items: items);
  }
}
