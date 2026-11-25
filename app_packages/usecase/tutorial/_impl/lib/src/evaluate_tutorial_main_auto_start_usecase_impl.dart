import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

/// 永続と session からメイン自動開始要否を決める。
///
/// Example:
/// ```dart
/// EvaluateTutorialMainAutoStartUsecaseImpl(
///   repository: repository,
///   session: session,
/// );
/// ```
final class EvaluateTutorialMainAutoStartUsecaseImpl
    implements EvaluateTutorialMainAutoStartUsecase {
  /// [repository] と [session] を使う。
  ///
  /// Example:
  /// ```dart
  /// EvaluateTutorialMainAutoStartUsecaseImpl(
  ///   repository: repository,
  ///   session: session,
  /// );
  /// ```
  EvaluateTutorialMainAutoStartUsecaseImpl({
    required this.repository,
    required this.session,
  });

  /// チュートリアル進捗。
  final TutorialRepository repository;

  /// プロセス内実行状態。
  final TutorialRuntimeSession session;

  /// suppress / guard / 表示中 / 完了済みなら false。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<EvaluateTutorialMainAutoStartResult> execute() async {
    if (session.suppressMainAutoStartThisProcess || session.manualStartGuard) {
      return const EvaluateTutorialMainAutoStartResult(shouldStart: false);
    }
    if (session.isShowing) {
      return const EvaluateTutorialMainAutoStartResult(shouldStart: false);
    }
    final progress = await repository.read();
    if (progress.mainCompleted) {
      return const EvaluateTutorialMainAutoStartResult(shouldStart: false);
    }
    return const EvaluateTutorialMainAutoStartResult(shouldStart: true);
  }
}
