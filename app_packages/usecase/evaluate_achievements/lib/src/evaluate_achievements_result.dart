import 'package:domain_achievement/domain_achievement.dart';

/// アチーブメント評価の結果。
///
/// Example:
/// ```dart
/// const EvaluateAchievementsResult(newlyUnlocked: []);
/// ```
final class EvaluateAchievementsResult {
  /// トースト通知対象の新規獲得一覧を持つ。
  ///
  /// Example:
  /// ```dart
  /// const EvaluateAchievementsResult(newlyUnlocked: []);
  /// ```
  const EvaluateAchievementsResult({required this.newlyUnlocked});

  /// 今回の評価でトーストに出す新規獲得。初回遡及や emit 無効時は空。
  final List<AchievementUnlock> newlyUnlocked;
}
