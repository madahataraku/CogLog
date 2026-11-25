import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/top_screen_state.dart';

/// アチーブメント文脈の表示要否を見て pending を立てる。
///
/// Example:
/// ```dart
/// OnEvaluateTutorialAchievementDelegate(
///   state: state,
///   loadAchievements: loadAchievements,
///   evaluateContext: evaluateContext,
///   now: DateTime.now,
/// ).execute();
/// ```
final class OnEvaluateTutorialAchievementDelegate {
  /// 依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEvaluateTutorialAchievementDelegate(
  ///   state: state,
  ///   loadAchievements: loadAchievements,
  ///   evaluateContext: evaluateContext,
  ///   now: DateTime.now,
  /// );
  /// ```
  const OnEvaluateTutorialAchievementDelegate({
    required this.state,
    required this.loadAchievements,
    required this.evaluateContext,
    required this.now,
  });

  /// 画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 獲得件数取得。
  final LoadAchievementsUsecase loadAchievements;

  /// 文脈判定。
  final EvaluateTutorialContextUsecase evaluateContext;

  /// 一覧読込の基準時刻。
  final DateTime Function() now;

  /// 獲得 1 件以上かつ条件成立なら pendingTutorialAchievement を立てる。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    if (!state.state.loaded) {
      return;
    }
    final loaded = await loadAchievements.execute(
      LoadAchievementsRequest(now: now()),
    );
    final unlocked = switch (loaded) {
      LoadAchievementsSuccess(:final rows) =>
        rows.where((e) => e.unlocked).length,
      _ => 0,
    };
    final decision = await evaluateContext.execute(
      EvaluateTutorialContextRequest(
        kind: TutorialKind.achievement,
        unlockedAchievementCount: unlocked,
      ),
    );
    if (!decision.shouldShow) {
      return;
    }
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(pendingTutorialAchievement: true));
    });
  }
}
