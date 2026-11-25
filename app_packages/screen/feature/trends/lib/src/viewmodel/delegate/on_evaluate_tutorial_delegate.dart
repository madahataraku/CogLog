import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/trends_screen_state.dart';

/// 推移文脈（段階7）の表示要否を見て pending を立てる。
///
/// Ready（非 loading）後に呼ぶ。
///
/// Example:
/// ```dart
/// OnEvaluateTutorialDelegate(
///   state: state,
///   evaluateContext: evaluateContext,
/// ).execute();
/// ```
final class OnEvaluateTutorialDelegate {
  /// [state] と文脈判定を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateTutorialDelegate(
  ///   state: state,
  ///   evaluateContext: evaluateContext,
  /// );
  /// ```
  const OnEvaluateTutorialDelegate({
    required this.state,
    required this.evaluateContext,
  });

  /// 画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// 文脈判定。
  final EvaluateTutorialContextUsecase evaluateContext;

  /// 非 loading なら Evaluate(trends) し pendingTutorial を立てる。
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
      const EvaluateTutorialContextRequest(kind: TutorialKind.trends),
    );
    if (!decision.shouldShow) {
      return;
    }
    await state.updateWithLock((s, emitter) async {
      await emitter.emit(s.copyWith(pendingTutorial: true));
    });
  }
}
