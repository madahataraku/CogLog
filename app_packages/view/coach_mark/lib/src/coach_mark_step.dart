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
  /// ターゲットと文言、操作可否を束ねる。
  ///
  /// [allowTargetInteraction] が true のときハイライト内のポインタを透過する。
  /// [blockSystemBack] が false のとき OS 戻るを呼び出し側がスキップ扱いできる。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkStep(
  ///   targetId: CoachMarkTargetId.goalDailyInputs,
  ///   title: 't',
  ///   body: 'b',
  ///   primaryLabel: '次へ',
  ///   secondaryLabel: 'スキップ',
  ///   allowTargetInteraction: true,
  ///   blockSystemBack: false,
  /// );
  /// ```
  const CoachMarkStep({
    required this.targetId,
    required this.title,
    required this.body,
    required this.primaryLabel,
    this.secondaryLabel,
    this.allowTargetInteraction = false,
    this.blockSystemBack = true,
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

  /// true のときハイライト内のポインタを透過（段階3）。
  final bool allowTargetInteraction;

  /// true のとき OS 戻るを握りつぶす（段階3は false）。
  final bool blockSystemBack;
}
