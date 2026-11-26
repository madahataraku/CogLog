import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/top_screen_state.dart';

/// メーター VL誘導 (B) の要否を判定し、予約する。
///
/// Example:
/// ```dart
/// OnEvaluateMeterVlGuidanceDelegate(
///   state: state,
///   evaluateMeterVlGuidanceUsecase: evaluate,
///   meterVlSession: meterVlSession,
/// ).execute();
/// ```
@internal
final class OnEvaluateMeterVlGuidanceDelegate {
  /// [state]・判定 Usecase・(B) セッションを受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateMeterVlGuidanceDelegate(
  ///   state: state,
  ///   evaluateMeterVlGuidanceUsecase: evaluate,
  ///   meterVlSession: meterVlSession,
  /// );
  /// ```
  const OnEvaluateMeterVlGuidanceDelegate({
    required this.state,
    required this.evaluateMeterVlGuidanceUsecase,
    required this.meterVlSession,
  });

  /// 更新する画面状態。
  final MutableStateStream<TopScreenState> state;

  /// メーター VL 誘導の要否。
  final EvaluateMeterVlGuidanceUsecase evaluateMeterVlGuidanceUsecase;

  /// プロセス内の (B) 再表示抑制。
  final MeterVlGuidanceSession meterVlSession;

  /// 未提示かつ判定が true のとき [TopScreenState.pendingMeterVlGuidance] を立てる。
  ///
  /// emit 直前にも [MeterVlGuidanceSession.shouldShow] を再確認し、
  /// 表示開始とのレースを避ける。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (!meterVlSession.shouldShow) {
      return;
    }
    final decision = await evaluateMeterVlGuidanceUsecase.execute();
    if (!decision.shouldShow || !meterVlSession.shouldShow) {
      return;
    }
    try {
      await state.updateWithLock((current, emitter) async {
        if (!meterVlSession.shouldShow) {
          return;
        }
        await emitter.emit(current.copyWith(pendingMeterVlGuidance: true));
      });
    } on StateStreamClosedException {
      // 評価完了前に画面が破棄されたときは更新しない。
      return;
    }
  }
}
