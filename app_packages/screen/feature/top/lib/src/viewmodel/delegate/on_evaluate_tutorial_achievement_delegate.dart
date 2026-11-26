import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

import '../state/top_screen_state.dart';

/// 旧アチーブメント文脈用。案内はメイン段階7へ移したため常に何もしない。
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
  /// 依存を受け取る（互換のためシグネチャ維持）。
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

  /// 獲得件数取得（未使用）。
  final LoadAchievementsUsecase loadAchievements;

  /// 文脈判定（未使用）。
  final EvaluateTutorialContextUsecase evaluateContext;

  /// 一覧読込の基準時刻（未使用）。
  final DateTime Function() now;

  /// 何もしない。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {}
}
