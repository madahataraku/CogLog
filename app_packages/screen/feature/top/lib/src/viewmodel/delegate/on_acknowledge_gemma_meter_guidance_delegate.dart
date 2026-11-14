import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/top_screen_state.dart';

/// Gemma 誘導予約を消費し、同一プロセスの再表示を止める。
///
/// Example:
/// ```dart
/// OnAcknowledgeGemmaMeterGuidanceDelegate(
///   state: state,
///   session: session,
/// ).execute();
/// ```
@internal
final class OnAcknowledgeGemmaMeterGuidanceDelegate {
  /// [state] と [session] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeGemmaMeterGuidanceDelegate(
  ///   state: state,
  ///   session: session,
  /// );
  /// ```
  const OnAcknowledgeGemmaMeterGuidanceDelegate({
    required this.state,
    required this.session,
  });

  /// 更新する画面状態。
  final MutableStateStream<TopScreenState> state;

  /// プロセス内 (B) セッション。
  final GemmaMeterGuidanceSession session;

  /// pending を false にし、[GemmaMeterGuidanceSession.markPresented] する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    session.markPresented();
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingGemmaMeterGuidance: false));
    });
  }
}
