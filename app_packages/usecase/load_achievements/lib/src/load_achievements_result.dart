import 'achievement_row.dart';

/// アチーブメント一覧読み込みの結果。
///
/// Example:
/// ```dart
/// const LoadAchievementsFailed();
/// ```
sealed class LoadAchievementsResult {
  /// 結果の共通口。
  const LoadAchievementsResult();
}

/// 一覧の成功結果。
///
/// Example:
/// ```dart
/// const LoadAchievementsSuccess([]);
/// ```
final class LoadAchievementsSuccess extends LoadAchievementsResult {
  /// カタログ順の [rows] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const LoadAchievementsSuccess([]);
  /// ```
  const LoadAchievementsSuccess(this.rows);

  /// 画面表示用の行。並びはカタログ順。
  final List<AchievementRow> rows;
}

/// 読み込み失敗。
///
/// Example:
/// ```dart
/// const LoadAchievementsFailed();
/// ```
final class LoadAchievementsFailed extends LoadAchievementsResult {
  /// 失敗を表す。
  ///
  /// Example:
  /// ```dart
  /// const LoadAchievementsFailed();
  /// ```
  const LoadAchievementsFailed();
}
