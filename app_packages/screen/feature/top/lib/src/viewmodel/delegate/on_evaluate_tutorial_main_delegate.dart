import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/top_screen_state.dart';

/// メイン自動開始要否を見て pending を立てる。
///
/// Example:
/// ```dart
/// OnEvaluateTutorialMainDelegate(
///   state: state,
///   evaluateUsecase: evaluateUsecase,
///   advanceUsecase: advanceUsecase,
/// ).execute();
/// ```
final class OnEvaluateTutorialMainDelegate {
  /// State と Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateTutorialMainDelegate(
  ///   state: state,
  ///   evaluateUsecase: evaluateUsecase,
  ///   advanceUsecase: advanceUsecase,
  /// );
  /// ```
  const OnEvaluateTutorialMainDelegate({
    required this.state,
    required this.evaluateUsecase,
    required this.advanceUsecase,
  });

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 自動開始判定。
  final EvaluateTutorialMainAutoStartUsecase evaluateUsecase;

  /// 段階1開始。
  final AdvanceTutorialMainUsecase advanceUsecase;

  /// shouldStart なら Advance.start し pendingTutorialMain を立てる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (!state.state.loaded) {
      return;
    }
    final decision = await evaluateUsecase.execute();
    if (!decision.shouldStart) {
      return;
    }
    // 判定待ち中に別 evaluate が pending を立てていれば二重起動しない。
    if (state.state.pendingTutorialMain) {
      return;
    }
    final advanced = await advanceUsecase.execute(
      const AdvanceTutorialMainRequest.start(),
    );
    if (advanced is! AdvanceTutorialMainShowResult) {
      return;
    }
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          pendingTutorialMain: true,
          tutorialMainStep: advanced.step,
        ),
      );
    });
  }
}
