import 'achievement_unlock.dart';

/// [unlock] が最終閲覧より後なら新規。
///
/// [lastViewedAt] が null のときは常に false（初回初期化前）。
///
/// Example:
/// ```dart
/// achievementIsNew(
///   unlock: AchievementUnlock(
///     id: 'first_record',
///     unlockedAt: DateTime.utc(2026, 11, 11),
///   ),
///   lastViewedAt: DateTime.utc(2026, 11, 10),
/// );
/// ```
bool achievementIsNew({
  required AchievementUnlock unlock,
  required DateTime? lastViewedAt,
}) {
  if (lastViewedAt == null) {
    return false;
  }
  return unlock.unlockedAt.toUtc().isAfter(lastViewedAt.toUtc());
}
