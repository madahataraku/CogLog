import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/meter_capture_screen_state.dart';

/// 読み取り中にコーチマークを隠し、提示済みにしない。
///
/// pending を下ろし、camera / meterEdit の [TutorialRuntimeSession.activeKind]
/// だけ消す。永続の *ContextSeen とプロセス内 presented は触らない。
///
/// Example:
/// ```dart
/// OnSuppressTutorialForReadingDelegate(
///   state: state,
///   session: session,
/// ).execute();
/// ```
final class OnSuppressTutorialForReadingDelegate {
  /// [state] と [session] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSuppressTutorialForReadingDelegate(
  ///   state: state,
  ///   session: session,
  /// );
  /// ```
  const OnSuppressTutorialForReadingDelegate({
    required this.state,
    required this.session,
  });

  /// 画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// プロセス内実行状態。
  final TutorialRuntimeSession session;

  /// pending を下ろし、撮影／編集文脈の activeKind を消す。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final kind = session.activeKind;
    if (kind == TutorialKind.camera || kind == TutorialKind.meterEdit) {
      session.clearActive();
    }
    await state.updateWithLock((current, emitter) async {
      if (!current.pendingTutorialCamera && !current.pendingTutorialMeterEdit) {
        return;
      }
      await emitter.emit(
        current.copyWith(
          pendingTutorialCamera: false,
          pendingTutorialMeterEdit: false,
        ),
      );
    });
  }
}
