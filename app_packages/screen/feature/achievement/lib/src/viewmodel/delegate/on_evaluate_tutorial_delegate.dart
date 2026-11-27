import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../rollback_achievement_tutorial_session.dart';
import '../state/achievement_screen_state.dart';

/// アチーブメント文脈の表示要否を見て pending を立てる。
///
/// Ready 後に呼ぶ。判定待ち中に読込が始まっていれば session の提示済みを戻す。
///
/// Example:
/// ```dart
/// OnEvaluateTutorialDelegate(
///   state: state,
///   evaluateContext: evaluateContext,
///   session: session,
/// ).execute();
/// ```
final class OnEvaluateTutorialDelegate {
  /// [state]・文脈判定・[session] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateTutorialDelegate(
  ///   state: state,
  ///   evaluateContext: evaluateContext,
  ///   session: session,
  /// );
  /// ```
  const OnEvaluateTutorialDelegate({
    required this.state,
    required this.evaluateContext,
    required this.session,
  });

  /// 画面状態。
  final MutableStateStream<AchievementScreenState> state;

  /// 文脈判定。
  final EvaluateTutorialContextUsecase evaluateContext;

  /// プロセス内提示済みのロールバック用。
  final TutorialRuntimeSession session;

  /// Ready なら Evaluate(achievement) し pendingTutorial を立てる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final current = state.state;
    if (current is! AchievementScreenReady || current.pendingTutorial) {
      return;
    }
    final decision = await evaluateContext.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.achievement),
    );
    if (!decision.shouldShow) {
      return;
    }
    final after = state.state;
    if (after is! AchievementScreenReady || after.pendingTutorial) {
      rollbackAchievementTutorialSession(session);
      return;
    }
    await state.updateWithLock((s, emitter) async {
      if (s is! AchievementScreenReady || s.pendingTutorial) {
        rollbackAchievementTutorialSession(session);
        return;
      }
      await emitter.emit(s.copyWith(pendingTutorial: true));
    });
  }
}
