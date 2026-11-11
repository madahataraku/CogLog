import 'achievement_id.dart';

/// 1 件のアチーブメントに対する現在の進捗。
///
/// 獲得済みフラグは永続化せず、履歴から都度この値を再計算する。
///
/// Example:
/// ```dart
/// const progress = AchievementProgress(
///   id: 'streak_3',
///   current: 2,
///   target: 3,
///   ratio: 2 / 3,
///   achieved: false,
///   binaryProgress: false,
/// );
/// ```
final class AchievementProgress {
  /// 識別子と現在値・目標・達成率・達成可否・二値表示を持つ進捗を作る。
  ///
  /// [ratio] は 0.0 以上 1.0 以下。二値条件では達成時 1.0、未達時 0.0。
  ///
  /// Example:
  /// ```dart
  /// AchievementProgress(
  ///   id: 'first_record',
  ///   current: 1,
  ///   target: 1,
  ///   ratio: 1,
  ///   achieved: true,
  ///   binaryProgress: true,
  /// );
  /// ```
  const AchievementProgress({
    required this.id,
    required this.current,
    required this.target,
    required this.ratio,
    required this.achieved,
    required this.binaryProgress,
  });

  /// 対象アチーブメントの識別子。
  final AchievementId id;

  /// 条件に対する現在値。単位は定義の目標値に合わせる。
  final double current;

  /// 達成に必要な目標値。
  final double target;

  /// 達成率。0.0 以上 1.0 以下。
  final double ratio;

  /// 目標を満たしているか。
  final bool achieved;

  /// 進捗を達成／未達の二値で表示するか。カタログ定義の同名フラグを引き継ぐ。
  final bool binaryProgress;
}
