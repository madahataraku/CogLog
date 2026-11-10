import 'exercise_history.dart';

/// 連続運動日数の算出。
///
/// Example:
/// ```dart
/// ConsecutiveExerciseDays.of(const [], DateTime(2026, 11, 5));
/// ```
final class ConsecutiveExerciseDays {
  /// 計算用の名前空間。
  ///
  /// Example:
  /// ```dart
  /// ConsecutiveExerciseDays.of(const [], DateTime(2026, 11, 5));
  /// ```
  const ConsecutiveExerciseDays._();

  /// [now] の現地日付を起点に、記録がある日が何日連続しているかを返す。
  ///
  /// 本日に履歴が無ければ 0。記録日時は現地時刻へ直して日付を取る。
  ///
  /// Example:
  /// ```dart
  /// ConsecutiveExerciseDays.of(histories, DateTime(2026, 11, 5, 15));
  /// ```
  static int of(List<ExerciseHistory> histories, DateTime now) {
    final local = now.toLocal();
    final daysWithHistory = <DateTime>{};
    for (final history in histories) {
      final recorded = history.recordedAt.toLocal();
      daysWithHistory.add(
        DateTime(recorded.year, recorded.month, recorded.day),
      );
    }
    var cursor = DateTime(local.year, local.month, local.day);
    var count = 0;
    while (daysWithHistory.contains(cursor)) {
      count += 1;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }
}
