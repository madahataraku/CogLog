import 'package:state_stream/state_stream.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/top_screen_state.dart';

/// ホーム側の旧アチーブメント文脈閉じ。案内はアチーブメント画面文脈へ移したため pending だけ下ろす。
///
/// Example:
/// ```dart
/// OnDismissTutorialAchievementDelegate(
///   state: state,
///   markSeen: markSeen,
/// ).execute();
/// ```
final class OnDismissTutorialAchievementDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnDismissTutorialAchievementDelegate(
  ///   state: state,
  ///   markSeen: markSeen,
  /// );
  /// ```
  const OnDismissTutorialAchievementDelegate({
    required this.state,
    required this.markSeen,
  });

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 文脈表示済み（未使用）。
  final MarkTutorialContextSeenUsecase markSeen;

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
