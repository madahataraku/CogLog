import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';

/// Repository から同一記録日の ID 列を組み立てる。
///
/// Example:
/// ```dart
/// LoadExerciseHistoriesForSameRecordedDayUsecaseImpl(
///   histories: histories,
/// ).execute(
///   const LoadExerciseHistoriesForSameRecordedDayRequest(id: 'id'),
/// );
/// ```
final class LoadExerciseHistoriesForSameRecordedDayUsecaseImpl
    implements LoadExerciseHistoriesForSameRecordedDayUsecase {
  /// [histories] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// LoadExerciseHistoriesForSameRecordedDayUsecaseImpl(histories: histories);
  /// ```
  const LoadExerciseHistoriesForSameRecordedDayUsecaseImpl({
    required this.histories,
  });

  /// 運動履歴の読み出し口。
  final ExerciseHistoryRepository histories;

  /// 記録日時の現地暦日が同じ件の ID を、作成開始日時降順で返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const LoadExerciseHistoriesForSameRecordedDayRequest(id: 'id'),
  /// );
  /// ```
  @override
  Future<LoadExerciseHistoriesForSameRecordedDayResult> execute(
    LoadExerciseHistoriesForSameRecordedDayRequest request,
  ) async {
    final history = await histories.findById(request.id);
    if (history == null) {
      return const LoadExerciseHistoriesForSameRecordedDayNotFound();
    }
    final local = history.recordedAt.toLocal();
    final monthItems = await histories.listByMonth(
      year: local.year,
      month: local.month,
    );
    final sameDay =
        monthItems.where((item) {
          final itemLocal = item.recordedAt.toLocal();
          return itemLocal.year == local.year &&
              itemLocal.month == local.month &&
              itemLocal.day == local.day;
        }).toList()..sort((a, b) {
          final byCreated = b.creationStartedAt.compareTo(a.creationStartedAt);
          if (byCreated != 0) {
            return byCreated;
          }
          return b.id.compareTo(a.id);
        });
    final ids = [for (final item in sameDay) item.id];
    final initialIndex = ids.indexOf(request.id);
    if (initialIndex < 0) {
      return const LoadExerciseHistoriesForSameRecordedDayNotFound();
    }
    return LoadExerciseHistoriesForSameRecordedDaySuccess(
      ids: ids,
      initialIndex: initialIndex,
    );
  }
}
