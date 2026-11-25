import 'package:state_stream/state_stream.dart';

import '../state/meter_capture_screen_state.dart';

/// 結果編集文脈の表示予約を消費する（表示直前）。
///
/// Example:
/// ```dart
/// OnAcknowledgeTutorialMeterEditDelegate(state: state).execute();
/// ```
final class OnAcknowledgeTutorialMeterEditDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeTutorialMeterEditDelegate(state: state);
  /// ```
  const OnAcknowledgeTutorialMeterEditDelegate({required this.state});

  /// 画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// pendingTutorialMeterEdit を下ろす。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingTutorialMeterEdit: false));
    });
  }
}
