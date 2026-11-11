import 'achievement_id.dart';

/// 獲得済みアチーブメントの記録。
///
/// 一度記録したら条件を満たさなくなっても取り消さない。
///
/// Example:
/// ```dart
/// final unlock = AchievementUnlock(
///   id: 'first_record',
///   unlockedAt: DateTime.utc(2026, 11, 10),
/// );
/// ```
final class AchievementUnlock {
  /// 識別子と獲得日時を持つ記録を作る。
  ///
  /// [unlockedAt] は UTC で保存する想定。
  ///
  /// Example:
  /// ```dart
  /// AchievementUnlock(
  ///   id: 'streak_3',
  ///   unlockedAt: DateTime.utc(2026, 11, 10, 12),
  /// );
  /// ```
  const AchievementUnlock({required this.id, required this.unlockedAt});

  /// 獲得したアチーブメントの識別子。
  final AchievementId id;

  /// 獲得日時。UTC を想定する。
  final DateTime unlockedAt;
}
