import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/meter_capture_screen_state.dart';

/// 撮影文脈を閉じ、表示済みにする。
///
/// Example:
/// ```dart
/// OnDismissTutorialCameraDelegate(
///   state: state,
///   markSeen: markSeen,
/// ).execute();
/// ```
final class OnDismissTutorialCameraDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnDismissTutorialCameraDelegate(
  ///   state: state,
  ///   markSeen: markSeen,
  /// );
  /// ```
  const OnDismissTutorialCameraDelegate({
    required this.state,
    required this.markSeen,
  });

  /// 画面状態。
  final MutableStateStream<MeterCaptureScreenState> state;

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
      const MarkTutorialContextSeenRequest(kind: TutorialKind.camera),
    );
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingTutorialCamera: false));
    });
  }
}
