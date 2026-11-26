import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/top_screen_state.dart';

/// メイン連鎖を中断し、復帰時に同じ段階から再開できるよう pending を戻す。
///
/// Example:
/// ```dart
/// OnParkTutorialMainDelegate(state: state)
///     .execute(TutorialMainStep.goalProgressIntro);
/// ```
final class OnParkTutorialMainDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnParkTutorialMainDelegate(state: state);
  /// ```
  const OnParkTutorialMainDelegate({required this.state});

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// [step] を残して pendingTutorialMain を立てる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute(TutorialMainStep.homeIntro);
  /// ```
  Future<void> execute(TutorialMainStep step) async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(pendingTutorialMain: true, tutorialMainStep: step),
      );
    });
  }
}
