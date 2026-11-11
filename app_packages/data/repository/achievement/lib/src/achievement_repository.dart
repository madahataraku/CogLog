import 'package:domain_achievement/domain_achievement.dart';
import 'package:riverpod/riverpod.dart';

/// アチーブメントの獲得記録をプロセス終了後も残す。
///
/// Example:
/// ```dart
/// repository.readUnlocks();
/// ```
abstract interface class AchievementRepository {
  /// 保存済みの獲得一覧を返す。無ければ空。
  ///
  /// Example:
  /// ```dart
  /// repository.readUnlocks();
  /// ```
  Future<List<AchievementUnlock>> readUnlocks();

  /// 未所持の id だけ追加する。既存 id の [AchievementUnlock.unlockedAt] は変えない。
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
  Future<void> mergeUnlocks(List<AchievementUnlock> unlocks);

  /// 最終閲覧日時を返す。未保存・破損は null。
  ///
  /// Example:
  /// ```dart
  /// repository.readLastViewedAt();
  /// ```
  Future<DateTime?> readLastViewedAt();

  /// 最終閲覧日時を UTC で保存する。
  ///
  /// Example:
  /// ```dart
  /// repository.writeLastViewedAt(DateTime.utc(2026, 11, 11));
  /// ```
  Future<void> writeLastViewedAt(DateTime viewedAt);
}

/// アチーブメント Repository の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// achievementRepositoryProvider;
/// ```
final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) => throw UnimplementedError('achievementRepositoryProvider'),
);
