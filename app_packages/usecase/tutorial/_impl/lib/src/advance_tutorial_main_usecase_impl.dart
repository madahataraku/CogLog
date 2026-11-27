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
      AdvanceTutorialMainGoalSavedRequest() =>
        const AdvanceTutorialMainResult.noop(),
    };
  }

  /// 未完了なら導入〜段階3開始、または段階4〜7を再開する。
  Future<AdvanceTutorialMainResult> _startOrResume() async {
    session.manualStartGuard = false;
    final progress = await repository.read();
    // 読込み待ち中に文脈が始まっていれば、メインは状態を上書きしない。
    if (session.activeKind != null && session.activeKind != TutorialKind.main) {
      return const AdvanceTutorialMainResult.noop();
    }
    // 既にメイン表示中なら導入へ戻さず、二重連鎖を避ける。
    if (session.activeKind == TutorialKind.main) {
      return const AdvanceTutorialMainResult.noop();
    }
    if (progress.mainCompleted) {
      return const AdvanceTutorialMainResult.noop();
    }
    if (progress.mainReachedStep < 3) {
      return _show(
        TutorialMainStep.usageIntro,
        navigation: AdvanceTutorialMainNavigation.none,
      );
    }
    if (progress.mainReachedStep == 3 && progress.goalSettingsContextSeen) {
      return _show(
        TutorialMainStep.meterRecommend,
        navigation: AdvanceTutorialMainNavigation.none,
      );
    }
    if (progress.mainReachedStep == 4 &&
        progress.cameraContextSeen &&
        progress.meterEditContextSeen) {
      return _show(
        TutorialMainStep.trendsRecommend,
        navigation: AdvanceTutorialMainNavigation.none,
      );
    }
    if (progress.mainReachedStep == 5 && progress.trendsContextSeen) {
      return _show(
        TutorialMainStep.historyRecommend,
        navigation: AdvanceTutorialMainNavigation.none,
      );
    }
    if (progress.mainReachedStep == 6 && progress.historyContextSeen) {
      return _show(
        TutorialMainStep.achievementRecommend,
        navigation: AdvanceTutorialMainNavigation.none,
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
      TutorialMainStep.usageIntro => _show(
        TutorialMainStep.homeIntro,
        navigation: AdvanceTutorialMainNavigation.none,
      ),
      TutorialMainStep.homeIntro => _show(
        TutorialMainStep.goalProgressIntro,
        navigation: AdvanceTutorialMainNavigation.none,
      ),
      TutorialMainStep.goalProgressIntro => _show(
        TutorialMainStep.goalRecommend,
        navigation: AdvanceTutorialMainNavigation.none,
      ),
      TutorialMainStep.goalRecommend => _enterGoalContext(),
      TutorialMainStep.meterRecommend => _persistReachedAndNavigate(
        4,
        TutorialMainStep.meterRecommend,
        AdvanceTutorialMainNavigation.meterCaptureTab,
      ),
      TutorialMainStep.trendsRecommend => _persistReachedAndNavigate(
        5,
        TutorialMainStep.trendsRecommend,
        AdvanceTutorialMainNavigation.trendsTab,
      ),
      TutorialMainStep.historyRecommend => _persistReachedAndNavigate(
        6,
        TutorialMainStep.historyRecommend,
        AdvanceTutorialMainNavigation.exerciseHistoryTab,
      ),
      TutorialMainStep.achievementRecommend => _completeMain(
        navigation: AdvanceTutorialMainNavigation.achievements,
      ),
    };
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
      navigation: AdvanceTutorialMainNavigation.goalSettingsTab,
    );
  }

  /// 段階4〜6の次へのあと到達段階を残し、対応タブへ誘導する。
  Future<AdvanceTutorialMainResult> _persistReachedAndNavigate(
    int reached,
    TutorialMainStep step,
    AdvanceTutorialMainNavigation navigation,
  ) async {
    try {
      final current = await repository.read();
      await repository.write(current.copyWith(mainReachedStep: reached));
    } on Object {
      session.suppressMainAutoStartThisProcess = true;
    }
    session.clearActive();
    return AdvanceTutorialMainResult.show(step: step, navigation: navigation);
  }

  /// session を更新して show を返す。
  Future<AdvanceTutorialMainResult> _show(
    TutorialMainStep step, {
    required AdvanceTutorialMainNavigation navigation,
  }) async {
    session.activeKind = TutorialKind.main;
    session.mainStep = step;
    return AdvanceTutorialMainResult.show(step: step, navigation: navigation);
  }

  /// mainCompleted を書き、失敗時は suppress。
  Future<AdvanceTutorialMainResult> _completeMain({
    AdvanceTutorialMainNavigation navigation =
        AdvanceTutorialMainNavigation.none,
  }) async {
    try {
      final current = await repository.read();
      await repository.write(
        current.copyWith(mainCompleted: true, mainReachedStep: 7),
      );
      session.clearActive();
      return AdvanceTutorialMainResult.completed(navigation: navigation);
    } on Object {
      session.suppressMainAutoStartThisProcess = true;
      session.clearActive();
      return AdvanceTutorialMainResult.completed(navigation: navigation);
    }
  }
}
