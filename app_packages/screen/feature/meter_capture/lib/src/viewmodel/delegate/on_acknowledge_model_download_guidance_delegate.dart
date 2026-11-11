import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/meter_capture_screen_state.dart';

/// 誘導予約を消費し、同一プロセスの再表示を止める。
///
/// Example:
/// ```dart
/// OnAcknowledgeModelDownloadGuidanceDelegate(
///   state: state,
///   session: session,
/// ).execute();
/// ```
@internal
final class OnAcknowledgeModelDownloadGuidanceDelegate {
  /// [state] と [session] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeModelDownloadGuidanceDelegate(
  ///   state: state,
  ///   session: session,
  /// );
  /// ```
  const OnAcknowledgeModelDownloadGuidanceDelegate({
    required this.state,
    required this.session,
  });

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// プロセス内セッション。
  final OnDeviceLlmGuidanceSession session;

  /// pending を false にし、[OnDeviceLlmGuidanceSession.markPresented] する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    session.markPresented();
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingModelDownloadGuidance: false));
    });
  }
}
