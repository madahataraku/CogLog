import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/exercise_history_screen_state.dart';

/// 運動履歴文脈（段階8）の表示要否を見て pending を立てる。
///
/// Ready（非 loading）後に呼ぶ。判定待ち中に読込が始まっていれば
/// session の提示済みを戻し、Ready 後の再評価に任せる。
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
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 文脈判定。
  final EvaluateTutorialContextUsecase evaluateContext;

  /// プロセス内提示済みのロールバック用。
  final TutorialRuntimeSession session;

  /// 非 loading なら Evaluate(history) し pendingTutorial を立てる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final current = state.state;
    if (current.loading || current.pendingTutorial) {
      return;
    }
    final decision = await evaluateContext.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.history),
    );
    if (!decision.shouldShow) {
      return;
    }
    // Evaluate は shouldShow 時点で提示済みにする。読込が挟まったら戻す。
    final after = state.state;
    if (after.loading || after.pendingTutorial) {
      _rollbackPresented();
      return;
    }
    await state.updateWithLock((s, emitter) async {
      if (s.loading || s.pendingTutorial) {
        _rollbackPresented();
        return;
      }
      await emitter.emit(s.copyWith(pendingTutorial: true));
    });
  }

  /// Evaluate が付けた history の提示済み／表示中だけを捨てる。
  void _rollbackPresented() {
    session.clearActive();
    session.clearContextPresented(TutorialKind.history);
  }
}
