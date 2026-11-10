/// 自動更新判定の依頼。
///
/// Example:
/// ```dart
/// EvaluateDailyGoalAutoUpdateRequest(now: DateTime(2026, 11, 5));
/// ```
final class EvaluateDailyGoalAutoUpdateRequest {
  /// [now] を基準時刻とする依頼を作る。
  ///
  /// Example:
  /// ```dart
  /// EvaluateDailyGoalAutoUpdateRequest(now: DateTime.timestamp());
  /// ```
  const EvaluateDailyGoalAutoUpdateRequest({required this.now});

  /// 判定に使う現在時刻（現地日付の基準）。
  final DateTime now;
}
