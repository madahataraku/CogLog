import 'package:state_stream/state_stream.dart';

import '../state/top_screen_state.dart';

/// メイン表示予約を消費する（表示直前）。
///
/// Example:
/// ```dart
/// OnAcknowledgeTutorialMainDelegate(state: state).execute();
/// ```
final class OnAcknowledgeTutorialMainDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeTutorialMainDelegate(state: state);
  /// ```
  const OnAcknowledgeTutorialMainDelegate({required this.state});

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// pendingTutorialMain を下ろす。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingTutorialMain: false));
    });
  }
}
