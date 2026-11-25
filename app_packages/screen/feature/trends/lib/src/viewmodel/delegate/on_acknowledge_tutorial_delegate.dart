import 'package:state_stream/state_stream.dart';

import '../state/trends_screen_state.dart';

/// 推移文脈の表示予約を消費する（表示直前）。
///
/// Example:
/// ```dart
/// OnAcknowledgeTutorialDelegate(state: state).execute();
/// ```
final class OnAcknowledgeTutorialDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeTutorialDelegate(state: state);
  /// ```
  const OnAcknowledgeTutorialDelegate({required this.state});

  /// 画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// pendingTutorial を下ろす。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingTutorial: false));
    });
  }
}
