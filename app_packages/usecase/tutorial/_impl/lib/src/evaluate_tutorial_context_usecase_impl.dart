import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

/// 文脈表示要否。メイン中なら中断する。
///
/// Example:
/// ```dart
/// EvaluateTutorialContextUsecaseImpl(
///   repository: repository,
///   session: session,
/// );
/// ```
final class EvaluateTutorialContextUsecaseImpl
    implements EvaluateTutorialContextUsecase {
  /// [repository] と [session] を使う。
  ///
  /// Example:
  /// ```dart
  /// EvaluateTutorialContextUsecaseImpl(
  ///   repository: repository,
  ///   session: session,
  /// );
  /// ```
  EvaluateTutorialContextUsecaseImpl({
    required this.repository,
    required this.session,
  });

  /// チュートリアル進捗。
  final TutorialRepository repository;

  /// プロセス内実行状態。
  final TutorialRuntimeSession session;

  /// [request] の文脈を出してよいか返す。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute(
  ///   const EvaluateTutorialContextRequest(kind: TutorialKind.camera),
  /// );
  /// ```
  @override
  Future<EvaluateTutorialContextResult> execute(
    EvaluateTutorialContextRequest request,
  ) async {
    final kind = request.kind;
    if (kind == TutorialKind.main) {
      return const EvaluateTutorialContextResult(shouldShow: false);
    }
    if (session.hasContextPresentedThisProcess(kind)) {
      return const EvaluateTutorialContextResult(shouldShow: false);
    }
    // 他文脈表示中は同時一文脈。
    if (session.isShowing && session.activeKind != TutorialKind.main) {
      return const EvaluateTutorialContextResult(shouldShow: false);
    }

    final progress = await repository.read();
    if (_alreadySeen(progress, kind)) {
      return const EvaluateTutorialContextResult(shouldShow: false);
    }

    if (kind == TutorialKind.goalSettings) {
      if (progress.mainCompleted || progress.mainReachedStep < 3) {
        return const EvaluateTutorialContextResult(shouldShow: false);
      }
    }

    if (session.activeKind == TutorialKind.main) {
      session.interruptMain();
    }

    session.activeKind = kind;
    session.mainStep = null;
    session.markContextPresented(kind);
    return const EvaluateTutorialContextResult(shouldShow: true);
  }

  /// 永続の表示済みフラグ。
  bool _alreadySeen(TutorialProgress progress, TutorialKind kind) {
    return switch (kind) {
      TutorialKind.goalSettings => progress.goalSettingsContextSeen,
      TutorialKind.camera => progress.cameraContextSeen,
      TutorialKind.meterEdit => progress.meterEditContextSeen,
      TutorialKind.trends => progress.trendsContextSeen,
      TutorialKind.history => progress.historyContextSeen,
      TutorialKind.main => true,
    };
  }
}
