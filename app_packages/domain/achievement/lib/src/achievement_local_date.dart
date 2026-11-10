import 'package:domain_exercise_history/domain_exercise_history.dart';

/// アチーブメント判定用の現地日付ヘルパー。
///
/// 記録日時は常に [DateTime.toLocal] してから年月日だけを残す。
///
/// Example:
/// ```dart
/// AchievementLocalDate.fromRecordedAt(DateTime.utc(2026, 11, 10, 15));
/// ```
final class AchievementLocalDate {
  /// ヘルパー用の名前空間。
  ///
  /// Example:
  /// ```dart
  /// AchievementLocalDate.fromDateTime(DateTime(2026, 11, 10, 15));
  /// ```
  const AchievementLocalDate._();

  /// [dateTime] を現地時刻へ直し、年月日だけの [DateTime] を返す。
  ///
  /// 時刻成分は捨てる。比較・集合演算はこの戻り値で行う。
  ///
  /// Example:
  /// ```dart
  /// AchievementLocalDate.fromDateTime(DateTime.utc(2026, 11, 10, 15));
  /// ```
  static DateTime fromDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// 履歴の [ExerciseHistory.recordedAt] から現地の年月日だけを取る。
  ///
  /// Example:
  /// ```dart
  /// AchievementLocalDate.fromHistory(history);
  /// ```
  static DateTime fromHistory(ExerciseHistory history) {
    return fromDateTime(history.recordedAt);
  }

  /// 履歴一覧からユニークな現地日付を昇順で返す。
  ///
  /// Example:
  /// ```dart
  /// AchievementLocalDate.uniqueSortedDays(histories);
  /// ```
  static List<DateTime> uniqueSortedDays(List<ExerciseHistory> histories) {
    final days = <DateTime>{};
    for (final history in histories) {
      days.add(fromHistory(history));
    }
    final sorted = days.toList()..sort();
    return sorted;
  }
}
