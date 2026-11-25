import 'package:state_stream/state_stream.dart';

import '../state/meter_capture_screen_state.dart';

/// 撮影文脈の表示予約を消費する（表示直前）。
///
/// Example:
/// ```dart
/// OnAcknowledgeTutorialCameraDelegate(state: state).execute();
/// ```
final class OnAcknowledgeTutorialCameraDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeTutorialCameraDelegate(state: state);
  /// ```
  const OnAcknowledgeTutorialCameraDelegate({required this.state});

  /// 画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// pendingTutorialCamera を下ろす。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingTutorialCamera: false));
    });
  }
}
