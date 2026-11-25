import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/exercise_history_screen_state.dart';

/// 運動履歴文脈を閉じ、表示済みにする。
///
/// Example:
/// ```dart
/// OnDismissTutorialDelegate(
///   state: state,
///   markSeen: markSeen,
/// ).execute();
/// ```
final class OnDismissTutorialDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnDismissTutorialDelegate(
  ///   state: state,
  ///   markSeen: markSeen,
  /// );
  /// ```
  const OnDismissTutorialDelegate({
    required this.state,
    required this.markSeen,
  });

  /// 画面状態。
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 文脈表示済み。
  final MarkTutorialContextSeenUsecase markSeen;

  /// MarkSeen し pending を下ろす。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    await markSeen.execute(
      const MarkTutorialContextSeenRequest(kind: TutorialKind.history),
    );
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingTutorial: false));
    });
  }
}
