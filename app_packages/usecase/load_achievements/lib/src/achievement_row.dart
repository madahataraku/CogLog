import 'package:domain_achievement/domain_achievement.dart';

/// 一覧 1 行分の表示用データ。
///
/// 表示名は View が [id] と [unlocked] から文言を解決する。
///
/// Example:
/// ```dart
/// const AchievementRow(
///   id: 'first_record',
///   unlocked: false,
///   current: 0,
///   target: 1,
///   progressRatio: 0,
///   binaryProgress: true,
///   isNew: false,
/// );
/// ```
final class AchievementRow {
  /// 識別子と進捗・獲得状態を持つ行を作る。
  ///
  /// Example:
  /// ```dart
  /// AchievementRow(
  ///   id: 'streak_3',
  ///   unlocked: true,
  ///   current: 3,
  ///   target: 3,
  ///   progressRatio: 1,
  ///   binaryProgress: false,
  ///   isNew: true,
  /// );
  /// ```
  const AchievementRow({
    required this.id,
    required this.unlocked,
    required this.current,
    required this.target,
    required this.progressRatio,
    required this.binaryProgress,
    required this.isNew,
  });

  /// アチーブメント識別子。文言キー解決に使う。
  final AchievementId id;

  /// 永続化された獲得済みか。
  final bool unlocked;

  /// 条件に対する現在値。
  final double current;

  /// 達成に必要な目標値。
  final double target;

  /// 達成率。0.0 以上 1.0 以下。
  final double progressRatio;

  /// 二値進捗か。画面の進捗バー表現に使う。
  final bool binaryProgress;

  /// 最終閲覧より後の獲得で、かつ開放済みのとき true。
  final bool isNew;
}
