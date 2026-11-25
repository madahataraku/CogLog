import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/meter_capture_screen_state.dart';
import '../state/meter_capture_step.dart';

/// 撮影画面（段階5）の文脈表示要否を見て pending を立てる。
///
/// 読み取り中は評価しない（提示済みにしない）。
///
/// Example:
/// ```dart
/// OnEvaluateTutorialCameraDelegate(
///   state: state,
///   evaluateContext: evaluateContext,
/// ).execute();
/// ```
final class OnEvaluateTutorialCameraDelegate {
  /// [state] と文脈判定を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateTutorialCameraDelegate(
  ///   state: state,
  ///   evaluateContext: evaluateContext,
  /// );
  /// ```
  const OnEvaluateTutorialCameraDelegate({
    required this.state,
    required this.evaluateContext,
  });

  /// 画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// 文脈判定。
  final EvaluateTutorialContextUsecase evaluateContext;

  /// photo かつ非読み取りなら Evaluate(camera) し pendingTutorialCamera を立てる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final current = state.state;
    if (current.step != MeterCaptureStep.photo || current.reading) {
      return;
    }
    if (current.pendingTutorialCamera) {
      return;
    }
    final decision = await evaluateContext.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.camera),
    );
    if (!decision.shouldShow) {
      return;
    }
    await state.updateWithLock((s, emitter) async {
      await emitter.emit(s.copyWith(pendingTutorialCamera: true));
    });
  }
}
