import 'package:domain_achievement/domain_achievement.dart';

/// 一覧 1 行の表示用。
///
/// Example:
/// ```dart
/// const AchievementRowEntity(
///   id: 'first_record',
///   name: '？？？？？',
///   condition: '初めて運動記録を登録する',
///   unlocked: false,
///   progressRatio: 0,
///   isNew: false,
/// );
/// ```
final class AchievementRowEntity {
  /// 表示名と条件・進捗・新規有無を持つ行を作る。
  ///
  /// Example:
  /// ```dart
  /// const AchievementRowEntity(
  ///   id: 'streak_3',
  ///   name: '三日坊主卒業',
  ///   condition: '3日間連続で運動する',
  ///   unlocked: true,
  ///   progressRatio: 1,
  ///   isNew: true,
  /// );
  /// ```
  const AchievementRowEntity({
    required this.id,
    required this.name,
    required this.condition,
    required this.unlocked,
    required this.progressRatio,
    required this.isNew,
  });

  /// アチーブメント識別子。
  final AchievementId id;

  /// 行タイトル。未開放時はロック表示名。
  final String name;

  /// 達成条件文。開放・未開放とも出す。
  final String condition;

  /// 獲得済みか。
  final bool unlocked;

  /// 進捗率。ゲージに使う。
  final double progressRatio;

  /// 新規獲得ドットを出すとき true。
  final bool isNew;
}
