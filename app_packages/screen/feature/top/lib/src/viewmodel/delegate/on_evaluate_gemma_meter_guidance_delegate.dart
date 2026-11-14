import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_gemma_meter_guidance/usecase_gemma_meter_guidance.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/top_screen_state.dart';

/// Gemma メーター誘導 (B) の要否を判定し、予約する。
///
/// Example:
/// ```dart
/// OnEvaluateGemmaMeterGuidanceDelegate(
///   state: state,
///   evaluateGemmaMeterGuidanceUsecase: evaluate,
///   gemmaSession: gemmaSession,
/// ).execute();
/// ```
@internal
final class OnEvaluateGemmaMeterGuidanceDelegate {
  /// [state]・判定 Usecase・(B) セッションを受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateGemmaMeterGuidanceDelegate(
  ///   state: state,
  ///   evaluateGemmaMeterGuidanceUsecase: evaluate,
  ///   gemmaSession: gemmaSession,
  /// );
  /// ```
  const OnEvaluateGemmaMeterGuidanceDelegate({
    required this.state,
    required this.evaluateGemmaMeterGuidanceUsecase,
    required this.gemmaSession,
  });

  /// 更新する画面状態。
  final MutableStateStream<TopScreenState> state;

  /// Gemma 誘導の要否。
  final EvaluateGemmaMeterGuidanceUsecase evaluateGemmaMeterGuidanceUsecase;

  /// プロセス内の (B) 再表示抑制。
  final GemmaMeterGuidanceSession gemmaSession;

  /// 未提示かつ判定が true のとき [TopScreenState.pendingGemmaMeterGuidance] を立てる。
  ///
  /// emit 直前にも [GemmaMeterGuidanceSession.shouldShow] を再確認し、
  /// 表示開始とのレースを避ける。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (!gemmaSession.shouldShow) {
      return;
    }
    final decision = await evaluateGemmaMeterGuidanceUsecase.execute();
    if (!decision.shouldShow || !gemmaSession.shouldShow) {
      return;
    }
    await state.updateWithLock((current, emitter) async {
      if (!gemmaSession.shouldShow) {
        return;
      }
      await emitter.emit(current.copyWith(pendingGemmaMeterGuidance: true));
    });
  }
}
