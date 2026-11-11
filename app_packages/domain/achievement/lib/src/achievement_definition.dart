import 'achievement_criterion.dart';
import 'achievement_id.dart';

/// カタログ上の 1 件のアチーブメント定義。
///
/// 表示順はカタログ一覧の並びで決まる。
///
/// Example:
/// ```dart
/// const definition = AchievementDefinition(
///   id: 'first_record',
///   criterion: AchievementCriterion.firstRecord,
///   target: 1,
///   binaryProgress: true,
/// );
/// ```
final class AchievementDefinition {
  /// 識別子・条件・目標値・進捗の二値可否を持つ定義を作る。
  ///
  /// [target] の単位は [criterion] に依存する（日数、km、秒、kcal、件数など）。
  /// [binaryProgress] が true のとき、進捗比は達成なら 1.0、未達なら 0.0。
  ///
  /// Example:
  /// ```dart
  /// AchievementDefinition(
  ///   id: 'streak_3',
  ///   criterion: AchievementCriterion.maxStreakDays,
  ///   target: 3,
  ///   binaryProgress: false,
  /// );
  /// ```
  const AchievementDefinition({
    required this.id,
    required this.criterion,
    required this.target,
    required this.binaryProgress,
  });

  /// カタログ内で一意な識別子。
  final AchievementId id;

  /// 達成条件の種別。
  final AchievementCriterion criterion;

  /// 達成に必要な目標値。単位は [criterion] に依存する。
  final double target;

  /// 進捗を二値（0 または 1）として扱うか。
  final bool binaryProgress;
}
