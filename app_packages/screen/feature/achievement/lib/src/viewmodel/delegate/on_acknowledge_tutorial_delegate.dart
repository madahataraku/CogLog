import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

import '../state/achievement_screen_state.dart';

/// アチーブメント文脈の表示予約を消費する。
///
/// Example:
/// ```dart
/// OnAcknowledgeTutorialDelegate(state: state).execute();
/// ```
@internal
final class OnAcknowledgeTutorialDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeTutorialDelegate(state: state);
  /// ```
  const OnAcknowledgeTutorialDelegate({required this.state});

  /// 画面状態。
  final MutableStateStream<AchievementScreenState> state;

  /// pendingTutorial を下ろす。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      if (current is! AchievementScreenReady) {
        return;
      }
      await emitter.emit(current.copyWith(pendingTutorial: false));
    });
  }
}
