import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/meter_capture_screen_state.dart';
import '../state/meter_capture_step.dart';

/// 結果編集（段階6）の文脈表示要否を見て pending を立てる。
///
/// 読み取り中は評価しない（提示済みにしない）。
///
/// Example:
/// ```dart
/// OnEvaluateTutorialMeterEditDelegate(
///   state: state,
///   evaluateContext: evaluateContext,
/// ).execute();
/// ```
final class OnEvaluateTutorialMeterEditDelegate {
  /// [state] と文脈判定を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateTutorialMeterEditDelegate(
  ///   state: state,
  ///   evaluateContext: evaluateContext,
  /// );
  /// ```
  const OnEvaluateTutorialMeterEditDelegate({
    required this.state,
    required this.evaluateContext,
  });

  /// 画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// 文脈判定。
  final EvaluateTutorialContextUsecase evaluateContext;

  /// edit かつ非読み取りなら Evaluate(meterEdit) し pending を立てる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final current = state.state;
    if (current.step != MeterCaptureStep.edit || current.reading) {
      return;
    }
    if (current.pendingTutorialMeterEdit) {
      return;
    }
    final decision = await evaluateContext.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.meterEdit),
    );
    if (!decision.shouldShow) {
      return;
    }
    await state.updateWithLock((s, emitter) async {
      await emitter.emit(s.copyWith(pendingTutorialMeterEdit: true));
    });
  }
}
