import 'coach_mark_target_id.dart';

/// 1 枚のコーチマーク内容。
///
/// Example:
/// ```dart
/// CoachMarkStep(
///   targetId: CoachMarkTargetId.homePeriodTotals,
///   title: 't',
///   body: 'b',
///   primaryLabel: '次へ',
/// );
/// ```
final class CoachMarkStep {
  /// ターゲットと文言を束ねる。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkStep(
  ///   targetId: CoachMarkTargetId.goalDailyInputs,
  ///   title: 't',
  ///   body: 'b',
  ///   primaryLabel: '次へ',
  ///   secondaryLabel: 'スキップ',
  /// );
  /// ```
  const CoachMarkStep({
    required this.targetId,
    required this.title,
    required this.body,
    required this.primaryLabel,
    this.secondaryLabel,
  });

  /// ハイライト対象。
  final CoachMarkTargetId targetId;

  /// 吹き出しタイトル。
  final String title;

  /// 吹き出し本文。
  final String body;

  /// 主ボタン（次へ／閉じる）。
  final String primaryLabel;

  /// 副ボタン（スキップ等）。null なら出さない。
  final String? secondaryLabel;
}
