/// アチーブメント一覧読み込みの依頼。
///
/// Example:
/// ```dart
/// LoadAchievementsRequest(now: DateTime(2026, 11, 10));
/// ```
final class LoadAchievementsRequest {
  /// [now] を進捗評価の基準時刻とする。
  ///
  /// Example:
  /// ```dart
  /// LoadAchievementsRequest(now: DateTime.timestamp());
  /// ```
  const LoadAchievementsRequest({required this.now});

  /// 進捗算出に使う現在時刻。
  final DateTime now;
}
