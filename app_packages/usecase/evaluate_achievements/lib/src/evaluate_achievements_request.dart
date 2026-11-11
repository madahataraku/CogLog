/// アチーブメント評価の依頼。
///
/// Example:
/// ```dart
/// EvaluateAchievementsRequest(
///   now: DateTime(2026, 11, 10),
///   emitNotifications: true,
/// );
/// ```
final class EvaluateAchievementsRequest {
  /// [now] を判定時点とし、[emitNotifications] でトースト用の差分を返すかを決める。
  ///
  /// Example:
  /// ```dart
  /// EvaluateAchievementsRequest(
  ///   now: DateTime.timestamp(),
  ///   emitNotifications: false,
  /// );
  /// ```
  const EvaluateAchievementsRequest({
    required this.now,
    required this.emitNotifications,
  });

  /// 判定に使う現在時刻。獲得日時は UTC へ変換して保存する。
  final DateTime now;

  /// true のとき、初回遡及以外の新規獲得を [EvaluateAchievementsResult.newlyUnlocked] に載せる。
  final bool emitNotifications;
}
