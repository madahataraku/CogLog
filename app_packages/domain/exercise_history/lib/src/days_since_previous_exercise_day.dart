import 'exercise_history.dart';

/// 直前運動日との暦日差の算出。
///
/// Example:
/// ```dart
/// DaysSincePreviousExerciseDay.of(const [], DateTime(2026, 11, 5));
/// ```
final class DaysSincePreviousExerciseDay {
  /// 計算用の名前空間。
  ///
  /// Example:
  /// ```dart
  /// DaysSincePreviousExerciseDay.of(const [], DateTime(2026, 11, 5));
  /// ```
  const DaysSincePreviousExerciseDay._();

  /// [now] の現地日付より前で最も新しい運動日との暦日差を返す。
  ///
  /// 直前運動日が無ければ null。差は (本日 - 直前日).inDays である。
  /// 記録日時は現地時刻へ直して日付を取る。
  ///
  /// Example:
  /// ```dart
  /// DaysSincePreviousExerciseDay.of(histories, DateTime(2026, 11, 5, 15));
  /// ```
  static int? of(List<ExerciseHistory> histories, DateTime now) {
    final local = now.toLocal();
    final today = DateTime(local.year, local.month, local.day);
    DateTime? previous;
    for (final history in histories) {
      final recorded = history.recordedAt.toLocal();
      final day = DateTime(recorded.year, recorded.month, recorded.day);
      if (!day.isBefore(today)) continue;
      if (previous == null || day.isAfter(previous)) previous = day;
    }
    if (previous == null) return null;
    return today.difference(previous).inDays;
  }
}
