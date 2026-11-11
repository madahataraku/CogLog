import 'package:data_repository_achievement/data_repository_achievement.dart';
import 'package:domain_achievement/domain_achievement.dart';

/// メモリ上の獲得一覧。初期値は空。
///
/// Example:
/// ```dart
/// final repository = MemoryAchievementRepository();
/// repository.mergeUnlocks([
///   AchievementUnlock(
///     id: 'first_record',
///     unlockedAt: DateTime.utc(2026, 11, 10),
///   ),
/// ]);
/// ```
final class MemoryAchievementRepository implements AchievementRepository {
  /// 空の獲得一覧で作る。
  ///
  /// Example:
  /// ```dart
  /// MemoryAchievementRepository();
  /// ```
  MemoryAchievementRepository();

  final Map<AchievementId, AchievementUnlock> _byId = {};

  /// まだ書いていなければ空。
  ///
  /// Example:
  /// ```dart
  /// repository.readUnlocks();
  /// ```
  @override
  Future<List<AchievementUnlock>> readUnlocks() async =>
      _byId.values.toList(growable: false);

  /// 未所持の id だけ足す。既存 id の獲得日時は変えない。
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
    for (final unlock in unlocks) {
      if (_byId.containsKey(unlock.id)) {
        continue;
      }
      _byId[unlock.id] = unlock;
    }
  }
}
