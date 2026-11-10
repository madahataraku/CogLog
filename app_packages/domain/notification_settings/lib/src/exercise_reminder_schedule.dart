import 'package:domain_exercise_history/domain_exercise_history.dart';

/// 運動履歴から次回一回のリマインド予定時刻を求める。
///
/// Example:
/// ```dart
/// ExerciseReminderSchedule.compute(histories: const [], now: DateTime.now());
/// ```
final class ExerciseReminderSchedule {
  /// インスタンス化しない。
  const ExerciseReminderSchedule._();

  /// [histories] と [now] から予定時刻を返す。予約できないときは null。
  ///
  /// Example:
  /// ```dart
  /// ExerciseReminderSchedule.compute(
  ///   histories: histories,
  ///   now: DateTime(2026, 11, 10, 12),
  /// );
  /// ```
  static DateTime? compute({
    required List<ExerciseHistory> histories,
    required DateTime now,
  }) {
    if (histories.isEmpty) {
      return null;
    }

    final localNow = now.toLocal();
    final today = DateTime(localNow.year, localNow.month, localNow.day);

    for (final history in histories) {
      final local = history.creationStartedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      if (day == today) {
        return null;
      }
    }

    final byDay = <DateTime, ExerciseHistory>{};
    for (final history in histories) {
      final local = history.creationStartedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      final existing = byDay[day];
      if (existing == null ||
          history.creationStartedAt.isAfter(existing.creationStartedAt)) {
        byDay[day] = history;
      }
    }

    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));
    if (days.isEmpty) {
      return null;
    }
    final selected = days.take(3).map((day) => byDay[day]!).toList();

    var startSum = 0;
    var durationSum = 0;
    for (final history in selected) {
      final local = history.creationStartedAt.toLocal();
      startSum += local.hour * 3600 + local.minute * 60 + local.second;
      durationSum += history.duration.inSeconds;
    }
    final n = selected.length;
    final avgStart = startSum ~/ n;
    final avgDuration = durationSum ~/ n;
    final offsetSeconds = avgStart - avgDuration;
    // 開始平均より運動時間が長い場合は当日 0:00 より前になるため予約しない。
    if (offsetSeconds < 0) {
      return null;
    }
    // Duration 加算だと DST 切替日に壁時計がずれるため、年月日と秒から組み立てる。
    final candidate = DateTime(
      today.year,
      today.month,
      today.day,
      0,
      0,
      offsetSeconds,
    );
    if (!candidate.isAfter(localNow)) {
      return null;
    }
    return candidate;
  }
}
