import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

/// メイン導線の段階遷移と完了永続。
///
/// Example:
/// ```dart
/// AdvanceTutorialMainUsecaseImpl(
///   repository: repository,
///   session: session,
///   loadDailyGoal: loadDailyGoal,
/// );
/// ```
final class AdvanceTutorialMainUsecaseImpl
    implements AdvanceTutorialMainUsecase {
  /// [repository]・[session]・[loadDailyGoal] を使う。
  ///
  /// Example:
  /// ```dart
  /// AdvanceTutorialMainUsecaseImpl(
  ///   repository: repository,
  ///   session: session,
  ///   loadDailyGoal: loadDailyGoal,
  /// );
  /// ```
  AdvanceTutorialMainUsecaseImpl({
    required this.repository,
    required this.session,
    required this.loadDailyGoal,
  });

  /// チュートリアル進捗。
  final TutorialRepository repository;

  /// プロセス内実行状態。
  final TutorialRuntimeSession session;

  /// 段階2→3/4 分岐用の一日あたり目標。
  final LoadDailyGoalUsecase loadDailyGoal;

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
      AdvanceTutorialMainStartRequest() => _start(),
      AdvanceTutorialMainNextRequest() => _next(),
      AdvanceTutorialMainSkipRequest() => _skip(),
      AdvanceTutorialMainGoalSavedRequest() => _goalSaved(),
    };
  }

  /// 段階1を開始する。
  ///
  /// Example:
  /// ```dart
  /// await _start();
  /// ```
  Future<AdvanceTutorialMainResult> _start() async {
    session.manualStartGuard = false;
    session.activeKind = TutorialKind.main;
    session.mainStep = TutorialMainStep.homeIntro;
    return const AdvanceTutorialMainResult.show(
      step: TutorialMainStep.homeIntro,
      navigateToGoalTab: false,
    );
  }

  /// 主ボタン進行。
  ///
  /// Example:
  /// ```dart
  /// await _next();
  /// ```
  Future<AdvanceTutorialMainResult> _next() async {
    final step = session.mainStep;
    if (step == null || session.activeKind != TutorialKind.main) {
      return const AdvanceTutorialMainResult.noop();
    }
    return switch (step) {
      TutorialMainStep.homeIntro => _show(
        TutorialMainStep.tabOverview,
        navigateToGoalTab: false,
      ),
      TutorialMainStep.tabOverview => _fromTabOverview(),
      TutorialMainStep.goalRecommend => const AdvanceTutorialMainResult.noop(),
      TutorialMainStep.meterRecommend => _completeMain(),
    };
  }

  /// 段階2から目標有無で 3 か 4 へ。
  ///
  /// Example:
  /// ```dart
  /// await _fromTabOverview();
  /// ```
  Future<AdvanceTutorialMainResult> _fromTabOverview() async {
    final result = await loadDailyGoal.execute(const LoadDailyGoalRequest());
    final goal = result.goal;
    if (goal.hasDuration && goal.hasCalories && goal.hasDistance) {
      return _show(TutorialMainStep.meterRecommend, navigateToGoalTab: false);
    }
    return _show(TutorialMainStep.goalRecommend, navigateToGoalTab: true);
  }

  /// 段階3スキップでメイン完了。
  ///
  /// Example:
  /// ```dart
  /// await _skip();
  /// ```
  Future<AdvanceTutorialMainResult> _skip() async {
    if (session.mainStep != TutorialMainStep.goalRecommend) {
      return const AdvanceTutorialMainResult.noop();
    }
    return _completeMain();
  }

  /// 段階3保存成功で段階4（指標成否不問）。
  ///
  /// Example:
  /// ```dart
  /// await _goalSaved();
  /// ```
  Future<AdvanceTutorialMainResult> _goalSaved() async {
    if (session.mainStep != TutorialMainStep.goalRecommend) {
      return const AdvanceTutorialMainResult.noop();
    }
    return _show(TutorialMainStep.meterRecommend, navigateToGoalTab: false);
  }

  /// session を更新して show を返す。
  ///
  /// Example:
  /// ```dart
  /// await _show(TutorialMainStep.homeIntro, navigateToGoalTab: false);
  /// ```
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
  ///
  /// Example:
  /// ```dart
  /// await _completeMain();
  /// ```
  Future<AdvanceTutorialMainResult> _completeMain() async {
    try {
      final current = await repository.read();
      await repository.write(current.copyWith(mainCompleted: true));
      session.clearActive();
      return const AdvanceTutorialMainResult.completed();
    } on Object {
      session.suppressMainAutoStartThisProcess = true;
      session.clearActive();
      return const AdvanceTutorialMainResult.completed();
    }
  }
}
