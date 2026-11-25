import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

/// メイン導線の段階遷移と完了永続。
///
/// Example:
/// ```dart
/// AdvanceTutorialMainUsecaseImpl(
///   repository: repository,
///   session: session,
/// );
/// ```
final class AdvanceTutorialMainUsecaseImpl
    implements AdvanceTutorialMainUsecase {
  /// [repository]・[session] を使う。
  ///
  /// Example:
  /// ```dart
  /// AdvanceTutorialMainUsecaseImpl(
  ///   repository: repository,
  ///   session: session,
  /// );
  /// ```
  AdvanceTutorialMainUsecaseImpl({
    required this.repository,
    required this.session,
  });

  /// チュートリアル進捗。
  final TutorialRepository repository;

  /// プロセス内実行状態。
  final TutorialRuntimeSession session;

  /// [request] に応じて session を更新し結果を返す。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute(const AdvanceTutorialMainRequest.start());
  /// ```
  @override
  Future<AdvanceTutorialMainResult> execute(
    AdvanceTutorialMainRequest request,
  ) async {
    return switch (request) {
      AdvanceTutorialMainStartRequest() => _startOrResume(),
      AdvanceTutorialMainNextRequest() => _next(),
      AdvanceTutorialMainSkipRequest() => _skip(),
      AdvanceTutorialMainGoalSavedRequest() =>
        const AdvanceTutorialMainResult.noop(),
    };
  }

  /// 未完了なら段階1〜3開始、または段階4〜7を再開する。
  Future<AdvanceTutorialMainResult> _startOrResume() async {
    session.manualStartGuard = false;
    final progress = await repository.read();
    if (progress.mainCompleted) {
      return const AdvanceTutorialMainResult.noop();
    }
    if (progress.mainReachedStep < 3) {
      return _show(TutorialMainStep.homeIntro, navigateToGoalTab: false);
    }
    if (progress.mainReachedStep == 3 && progress.goalSettingsContextSeen) {
      return _show(TutorialMainStep.meterRecommend, navigateToGoalTab: false);
    }
    if (progress.mainReachedStep == 4 &&
        progress.cameraContextSeen &&
        progress.meterEditContextSeen) {
      return _show(TutorialMainStep.trendsRecommend, navigateToGoalTab: false);
    }
    if (progress.mainReachedStep == 5 && progress.trendsContextSeen) {
      return _show(TutorialMainStep.historyRecommend, navigateToGoalTab: false);
    }
    if (progress.mainReachedStep == 6 && progress.historyContextSeen) {
      return _show(
        TutorialMainStep.achievementRecommend,
        navigateToGoalTab: false,
      );
    }
    return const AdvanceTutorialMainResult.noop();
  }

  /// 主ボタン進行。
  Future<AdvanceTutorialMainResult> _next() async {
    final step = session.mainStep;
    if (step == null || session.activeKind != TutorialKind.main) {
      return const AdvanceTutorialMainResult.noop();
    }
    return switch (step) {
      TutorialMainStep.homeIntro => _show(
        TutorialMainStep.goalProgressIntro,
        navigateToGoalTab: false,
      ),
      TutorialMainStep.goalProgressIntro => _show(
        TutorialMainStep.goalRecommend,
        navigateToGoalTab: false,
      ),
      TutorialMainStep.goalRecommend => _enterGoalContext(),
      TutorialMainStep.meterRecommend => _persistReached(4),
      TutorialMainStep.trendsRecommend => _persistReached(5),
      TutorialMainStep.historyRecommend => _persistReached(6),
      TutorialMainStep.achievementRecommend => _completeMain(),
    };
  }

  /// 段階3スキップでメイン完了。
  Future<AdvanceTutorialMainResult> _skip() async {
    if (session.mainStep != TutorialMainStep.goalRecommend) {
      return const AdvanceTutorialMainResult.noop();
    }
    return _completeMain();
  }

  /// 段階3の次へ: 到達3を永続し目標タブへ。文脈へ引き継ぐ。
  Future<AdvanceTutorialMainResult> _enterGoalContext() async {
    try {
      final current = await repository.read();
      await repository.write(current.copyWith(mainReachedStep: 3));
    } on Object {
      session.suppressMainAutoStartThisProcess = true;
    }
    session.clearActive();
    return const AdvanceTutorialMainResult.show(
      step: TutorialMainStep.goalRecommend,
      navigateToGoalTab: true,
    );
  }

  /// 段階4〜6を閉じたあと到達段階を残す（メイン未完了のまま）。
  Future<AdvanceTutorialMainResult> _persistReached(int step) async {
    try {
      final current = await repository.read();
      await repository.write(current.copyWith(mainReachedStep: step));
    } on Object {
      session.suppressMainAutoStartThisProcess = true;
    }
    session.clearActive();
    return const AdvanceTutorialMainResult.noop();
  }

  /// session を更新して show を返す。
  Future<AdvanceTutorialMainResult> _show(
    TutorialMainStep step, {
    required bool navigateToGoalTab,
  }) async {
    session.activeKind = TutorialKind.main;
    session.mainStep = step;
    return AdvanceTutorialMainResult.show(
      step: step,
      navigateToGoalTab: navigateToGoalTab,
    );
  }

  /// mainCompleted を書き、失敗時は suppress。
  Future<AdvanceTutorialMainResult> _completeMain() async {
    try {
      final current = await repository.read();
      await repository.write(
        current.copyWith(mainCompleted: true, mainReachedStep: 7),
      );
      session.clearActive();
      return const AdvanceTutorialMainResult.completed();
    } on Object {
      session.suppressMainAutoStartThisProcess = true;
      session.clearActive();
      return const AdvanceTutorialMainResult.completed();
    }
  }
}
