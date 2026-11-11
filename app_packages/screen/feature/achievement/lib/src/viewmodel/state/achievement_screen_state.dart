import 'package:usecase_load_achievements/usecase_load_achievements.dart';

/// アチーブメント画面の読込状態。
///
/// Example:
/// ```dart
/// AchievementScreenState.initial;
/// ```
sealed class AchievementScreenState {
  /// 状態の共通口。
  const AchievementScreenState();

  /// 初回読込前。
  static const initial = AchievementScreenLoading();
}

/// 一覧の読込中。
///
/// Example:
/// ```dart
/// const AchievementScreenLoading();
/// ```
final class AchievementScreenLoading extends AchievementScreenState {
  /// 読込中を表す。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreenLoading();
  /// ```
  const AchievementScreenLoading();
}

/// 一覧の読込成功。
///
/// Example:
/// ```dart
/// const AchievementScreenReady([]);
/// ```
final class AchievementScreenReady extends AchievementScreenState {
  /// カタログ順の [rows] を持つ。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreenReady([]);
  /// ```
  const AchievementScreenReady(this.rows);

  /// 表示用の行。並びはカタログ順。
  final List<AchievementRow> rows;
}

/// 一覧の読込失敗。
///
/// Example:
/// ```dart
/// const AchievementScreenFailed();
/// ```
final class AchievementScreenFailed extends AchievementScreenState {
  /// 失敗を表す。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreenFailed();
  /// ```
  const AchievementScreenFailed();
}
