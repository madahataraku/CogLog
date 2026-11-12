import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/meter_capture_screen_state.dart';

/// モデル未ダウンロード誘導の要否を判定し、必要なら pending を立てる。
///
/// Example:
/// ```dart
/// OnEvaluateModelDownloadGuidanceDelegate(
///   state: state,
///   evaluateOnDeviceLlmGuidanceUsecase: evaluate,
///   guidanceSession: session,
/// ).execute();
/// ```
@internal
final class OnEvaluateModelDownloadGuidanceDelegate {
  /// [state]・判定 Usecase・セッションを受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateModelDownloadGuidanceDelegate(
  ///   state: state,
  ///   evaluateOnDeviceLlmGuidanceUsecase: evaluate,
  ///   guidanceSession: session,
  /// );
  /// ```
  const OnEvaluateModelDownloadGuidanceDelegate({
    required this.state,
    required this.evaluateOnDeviceLlmGuidanceUsecase,
    required this.guidanceSession,
  });

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// モデル未ダウンロード誘導の要否。
  final EvaluateOnDeviceLlmGuidanceUsecase evaluateOnDeviceLlmGuidanceUsecase;

  /// プロセス内の誘導再表示抑制。
  final OnDeviceLlmGuidanceSession guidanceSession;

  /// 未提示かつ誘導対象なら [MeterCaptureScreenState.pendingModelDownloadGuidance] を true にする。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (!guidanceSession.shouldShow) {
      return;
    }
    final decision = await evaluateOnDeviceLlmGuidanceUsecase.execute();
    if (!decision.shouldShow || !guidanceSession.shouldShow) {
      return;
    }
    await state.updateWithLock((current, emitter) async {
      if (!guidanceSession.shouldShow) {
        return;
      }
      await emitter.emit(
        current.copyWith(
          pendingModelDownloadGuidance: true,
          showHandEntryGuidance: false,
        ),
      );
    });
  }
}
