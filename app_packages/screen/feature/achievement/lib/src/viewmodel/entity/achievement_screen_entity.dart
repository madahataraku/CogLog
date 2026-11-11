import 'achievement_row_entity.dart';

/// アチーブメント画面の表示用状態。
///
/// Example:
/// ```dart
/// const AchievementScreenLoadingEntity();
/// ```
sealed class AchievementScreenEntity {
  /// 表示状態の共通口。
  const AchievementScreenEntity();
}

/// 読込中の表示。
///
/// Example:
/// ```dart
/// const AchievementScreenLoadingEntity();
/// ```
final class AchievementScreenLoadingEntity extends AchievementScreenEntity {
  /// スピナー表示用。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreenLoadingEntity();
  /// ```
  const AchievementScreenLoadingEntity();
}

/// 一覧の表示。
///
/// Example:
/// ```dart
/// const AchievementScreenReadyEntity([]);
/// ```
final class AchievementScreenReadyEntity extends AchievementScreenEntity {
  /// [rows] をフラットに並べる。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreenReadyEntity([]);
  /// ```
  const AchievementScreenReadyEntity(this.rows);

  /// カタログ順の行。
  final List<AchievementRowEntity> rows;
}

/// 読込失敗の表示。
///
/// Example:
/// ```dart
/// const AchievementScreenFailedEntity();
/// ```
final class AchievementScreenFailedEntity extends AchievementScreenEntity {
  /// エラーと再試行用。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreenFailedEntity();
  /// ```
  const AchievementScreenFailedEntity();
}
