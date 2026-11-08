import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

/// Repository から詳細を読む。
///
/// Example:
/// ```dart
/// LoadExerciseHistoryDetailUsecaseImpl(histories: histories).execute(
///   const LoadExerciseHistoryDetailRequest(
///     id: '11111111-1111-4111-8111-111111111111',
///   ),
/// );
/// ```
final class LoadExerciseHistoryDetailUsecaseImpl
    implements LoadExerciseHistoryDetailUsecase {
  /// [histories] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadExerciseHistoryDetailUsecaseImpl(histories: histories);
  /// ```
  const LoadExerciseHistoryDetailUsecaseImpl({required this.histories});

  /// 運動履歴の読み出し。
  final ExerciseHistoryRepository histories;

  /// 無ければ [LoadExerciseHistoryDetailNotFound]、あれば写真パス付きで返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   const LoadExerciseHistoryDetailRequest(
  ///     id: '11111111-1111-4111-8111-111111111111',
  ///   ),
  /// );
  /// ```
  @override
  Future<LoadExerciseHistoryDetailResult> execute(
    LoadExerciseHistoryDetailRequest request,
  ) async {
    final history = await histories.findById(request.id);
    if (history == null) {
      return const LoadExerciseHistoryDetailNotFound();
    }
    final path = await histories.photoAbsolutePath(request.id);
    return LoadExerciseHistoryDetailSuccess(
      history: history,
      photoAbsolutePath: path,
    );
  }
}
