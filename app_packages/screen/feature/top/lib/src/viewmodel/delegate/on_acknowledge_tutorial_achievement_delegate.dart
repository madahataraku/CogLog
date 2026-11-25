import 'package:state_stream/state_stream.dart';

import '../state/top_screen_state.dart';

/// アチーブメント文脈の表示予約を消費する。
///
/// Example:
/// ```dart
/// OnAcknowledgeTutorialAchievementDelegate(state: state).execute();
/// ```
final class OnAcknowledgeTutorialAchievementDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnAcknowledgeTutorialAchievementDelegate(state: state);
  /// ```
  const OnAcknowledgeTutorialAchievementDelegate({required this.state});

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// pendingTutorialAchievement を下ろす。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingTutorialAchievement: false));
    });
  }
}
