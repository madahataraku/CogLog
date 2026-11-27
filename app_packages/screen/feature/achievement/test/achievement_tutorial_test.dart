import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_achievement/src/viewmodel/delegate/on_acknowledge_tutorial_delegate.dart';
import 'package:screen_feature_achievement/src/viewmodel/delegate/on_dismiss_tutorial_delegate.dart';
import 'package:screen_feature_achievement/src/viewmodel/delegate/on_evaluate_tutorial_delegate.dart';
import 'package:screen_feature_achievement/src/viewmodel/rollback_achievement_tutorial_session.dart';
import 'package:screen_feature_achievement/src/viewmodel/state/achievement_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

final class _FakeEvaluate implements EvaluateTutorialContextUsecase {
  TutorialKind? lastKind;

  @override
  Future<EvaluateTutorialContextResult> execute(
    EvaluateTutorialContextRequest request,
  ) async {
    lastKind = request.kind;
    return const EvaluateTutorialContextResult(shouldShow: true);
  }
}

final class _FakeMarkSeen implements MarkTutorialContextSeenUsecase {
  MarkTutorialContextSeenRequest? request;

  @override
  Future<void> execute(MarkTutorialContextSeenRequest request) async {
    this.request = request;
  }
}

void main() {
  test('Ready なら Evaluate(achievement) し pending を立てる', () async {
    final state = MutableStateStream<AchievementScreenState>(
      const AchievementScreenReady([]),
    );
    final evaluate = _FakeEvaluate();
    final session = TutorialRuntimeSession();
    await OnEvaluateTutorialDelegate(
      state: state,
      evaluateContext: evaluate,
      session: session,
    ).execute();
    expect(evaluate.lastKind, TutorialKind.achievement);
    expect((state.state as AchievementScreenReady).pendingTutorial, isTrue);
  });

  test('未 Ready なら Evaluate しない', () async {
    final state = MutableStateStream<AchievementScreenState>(
      const AchievementScreenLoading(),
    );
    final evaluate = _FakeEvaluate();
    await OnEvaluateTutorialDelegate(
      state: state,
      evaluateContext: evaluate,
      session: TutorialRuntimeSession(),
    ).execute();
    expect(evaluate.lastKind, isNull);
  });

  test('Acknowledge は pending を下ろす', () async {
    final state = MutableStateStream<AchievementScreenState>(
      const AchievementScreenReady([], pendingTutorial: true),
    );
    await OnAcknowledgeTutorialDelegate(state: state).execute();
    expect((state.state as AchievementScreenReady).pendingTutorial, isFalse);
  });

  test('Dismiss は MarkSeen(achievement) し pending を下ろす', () async {
    final state = MutableStateStream<AchievementScreenState>(
      const AchievementScreenReady([], pendingTutorial: true),
    );
    final markSeen = _FakeMarkSeen();
    await OnDismissTutorialDelegate(state: state, markSeen: markSeen).execute();
    expect(markSeen.request?.kind, TutorialKind.achievement);
    expect((state.state as AchievementScreenReady).pendingTutorial, isFalse);
  });

  test('rollback は achievement の提示済みと表示中だけ戻す', () {
    final session = TutorialRuntimeSession()
      ..activeKind = TutorialKind.achievement
      ..markContextPresented(TutorialKind.achievement)
      ..markContextPresented(TutorialKind.trends);
    rollbackAchievementTutorialSession(session);
    expect(session.activeKind, isNull);
    expect(
      session.hasContextPresentedThisProcess(TutorialKind.achievement),
      isFalse,
    );
    expect(session.hasContextPresentedThisProcess(TutorialKind.trends), isTrue);
  });
}
