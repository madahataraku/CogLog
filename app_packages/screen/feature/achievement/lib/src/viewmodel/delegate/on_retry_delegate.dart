import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';

import '../state/achievement_screen_state.dart';
import 'on_initialize_delegate.dart';

/// 一覧読込失敗を再試行する。
///
/// Example:
/// ```dart
/// OnRetryDelegate(
///   state: state,
///   loadUsecase: loadUsecase,
///   now: DateTime(2026, 11, 10),
/// );
/// ```
final class OnRetryDelegate {
  /// [state] と読込 Usecase、基準時刻を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRetryDelegate(
  ///   state: state,
  ///   loadUsecase: loadUsecase,
  ///   now: DateTime(2026, 11, 10),
  /// );
  /// ```
  const OnRetryDelegate({
    required this.state,
    required this.loadUsecase,
    required this.now,
  });

  /// 画面状態。
  final MutableStateStream<AchievementScreenState> state;

  /// 一覧の読込。
  final LoadAchievementsUsecase loadUsecase;

  /// 進捗算出の基準時刻。
  final DateTime now;

  /// 失敗中だけ読込中へ戻して再取得する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final shouldLoad = await state.updateWithLock((current, emitter) async {
      if (current is! AchievementScreenFailed) {
        return false;
      }
      await emitter.emit(const AchievementScreenLoading());
      return true;
    });
    if (!shouldLoad) {
      return;
    }
    await loadAchievementsIntoState(
      state: state,
      loadUsecase: loadUsecase,
      now: now,
    );
  }
}
