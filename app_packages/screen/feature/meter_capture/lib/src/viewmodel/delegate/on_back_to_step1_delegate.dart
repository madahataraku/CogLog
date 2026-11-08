import 'package:state_stream/state_stream.dart';

import '../state/meter_capture_screen_state.dart';

/// 2 ステップ目から 1 ステップ目へ戻し、作業中データを破棄する。
///
/// Example:
/// ```dart
/// OnBackToStep1Delegate(state: state).execute();
/// ```
final class OnBackToStep1Delegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnBackToStep1Delegate(state: state);
  /// ```
  const OnBackToStep1Delegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

  /// 初期状態へ置き換える。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((_, emitter) async {
      await emitter.emit(MeterCaptureScreenState.initial);
    });
  }
}
