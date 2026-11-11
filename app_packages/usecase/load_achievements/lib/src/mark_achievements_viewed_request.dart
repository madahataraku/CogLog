/// 最終閲覧日時を残す要求。
///
/// Example:
/// ```dart
/// MarkAchievementsViewedRequest(now: DateTime.utc(2026, 11, 11));
/// ```
final class MarkAchievementsViewedRequest {
  /// [now] を最終閲覧として残す。
  ///
  /// Example:
  /// ```dart
  /// MarkAchievementsViewedRequest(now: DateTime.timestamp());
  /// ```
  const MarkAchievementsViewedRequest({required this.now});

  /// 閲覧日時。UTC に直して保存する。
  final DateTime now;
}
