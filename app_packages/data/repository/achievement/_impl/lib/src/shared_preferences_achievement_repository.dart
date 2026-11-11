import 'dart:convert';

import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:domain_achievement/domain_achievement.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 獲得記録を SharedPreferences の JSON 配列へ残す。
///
/// Example:
/// ```dart
/// SharedPreferencesAchievementRepository(preferences).readUnlocks();
/// ```
final class SharedPreferencesAchievementRepository
    implements AchievementRepository {
  /// [preferences] へ読み書きする。
  ///
  /// Example:
  /// ```dart
  /// SharedPreferencesAchievementRepository(preferences);
  /// ```
  const SharedPreferencesAchievementRepository(this._preferences);

  /// 獲得一覧の JSON 配列キー。
  static const _unlocksKey = 'achievement_unlocks';

  /// 最終閲覧日時の ISO8601 キー。
  static const _lastViewedAtKey = 'achievement_last_viewed_at';

  /// カタログ上の既知 id。
  static final Set<AchievementId> _knownIds = {
    for (final definition in AchievementCatalog.all) definition.id,
  };

  /// 読み書き先。
  final SharedPreferences _preferences;

  /// キー無し・JSON 破損・型不正は空リスト。未知 id は捨てる。
  ///
  /// Example:
  /// ```dart
  /// repository.readUnlocks();
  /// ```
  @override
  Future<List<AchievementUnlock>> readUnlocks() async {
    final raw = _preferences.getString(_unlocksKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List<dynamic>) {
        return const [];
      }
      final unlocks = <AchievementUnlock>[];
      for (final entry in decoded) {
        final unlock = _parseUnlock(entry);
        if (unlock != null) {
          unlocks.add(unlock);
        }
      }
      return unlocks;
    } on Object {
      // 破損 JSON でも起動と評価を継続するため空にする。
      return const [];
    }
  }

  /// キー無し・破損・パース失敗は null。
  ///
  /// Example:
  /// ```dart
  /// repository.readLastViewedAt();
  /// ```
  @override
  Future<DateTime?> readLastViewedAt() async {
    final raw = _preferences.getString(_lastViewedAtKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(raw);
    return parsed?.toUtc();
  }

  /// UTC の ISO8601 で書き、失敗時は reload して例外を返す。
  ///
  /// Example:
  /// ```dart
  /// repository.writeLastViewedAt(DateTime.utc(2026, 11, 11));
  /// ```
  @override
  Future<void> writeLastViewedAt(DateTime viewedAt) async {
    final payload = viewedAt.toUtc().toIso8601String();
    var saved = false;
    try {
      saved = await _preferences.setString(_lastViewedAtKey, payload);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$_lastViewedAtKey を保存できなかった。');
    }
  }

  /// 未所持の id だけ足して書き戻す。既存の獲得日時は維持する。
  ///
  /// Example:
  /// ```dart
  /// repository.mergeUnlocks([
  ///   AchievementUnlock(
  ///     id: 'first_record',
  ///     unlockedAt: DateTime.utc(2026, 11, 10),
  ///   ),
  /// ]);
  /// ```
  @override
  Future<void> mergeUnlocks(List<AchievementUnlock> unlocks) async {
    final existing = await readUnlocks();
    final byId = <AchievementId, AchievementUnlock>{
      for (final unlock in existing) unlock.id: unlock,
    };
    for (final unlock in unlocks) {
      if (!_knownIds.contains(unlock.id)) {
        continue;
      }
      if (byId.containsKey(unlock.id)) {
        continue;
      }
      byId[unlock.id] = unlock;
    }
    await _writeUnlocks(byId.values.toList(growable: false));
  }

  /// JSON 1 要素を獲得記録にする。不正・未知 id は null。
  ///
  /// Example:
  /// ```dart
  /// SharedPreferencesAchievementRepository._parseUnlock({
  ///   'id': 'first_record',
  ///   'unlockedAt': '2026-11-10T00:00:00.000Z',
  /// });
  /// ```
  static AchievementUnlock? _parseUnlock(Object? entry) {
    if (entry is! Map) {
      return null;
    }
    final id = entry['id'];
    final unlockedAtRaw = entry['unlockedAt'];
    if (id is! String || unlockedAtRaw is! String) {
      return null;
    }
    if (!_knownIds.contains(id)) {
      return null;
    }
    final unlockedAt = DateTime.tryParse(unlockedAtRaw);
    if (unlockedAt == null) {
      return null;
    }
    return AchievementUnlock(id: id, unlockedAt: unlockedAt.toUtc());
  }

  /// [unlocks] を JSON 配列で書く。失敗時は reload して例外を返す。
  ///
  /// Example:
  /// ```dart
  /// await repository._writeUnlocks(const []);
  /// ```
  Future<void> _writeUnlocks(List<AchievementUnlock> unlocks) async {
    final payload = jsonEncode([
      for (final unlock in unlocks)
        <String, String>{
          'id': unlock.id,
          'unlockedAt': unlock.unlockedAt.toUtc().toIso8601String(),
        },
    ]);
    var saved = false;
    try {
      saved = await _preferences.setString(_unlocksKey, payload);
    } on Object {
      await _preferences.reload();
      rethrow;
    }
    if (!saved) {
      await _preferences.reload();
      throw StateError('$_unlocksKey を保存できなかった。');
    }
  }
}
