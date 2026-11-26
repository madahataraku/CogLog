import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:meta/meta.dart';

import 'coach_mark_dismiss_reason.dart';
import 'coach_mark_step.dart';

/// コーチマーク吹き出し（タイトル・本文・主／副ボタン）。
///
/// `tutorial_coach_mark` の [TargetContent] 子として使う。
///
/// Example:
/// ```dart
/// CoachMarkBubble(
///   step: CoachMarkStep(
///     targetId: CoachMarkTargetId.homePeriodTotals,
///     title: 't',
///     body: 'b',
///     primaryLabel: '次へ',
///   ),
///   onDismiss: (_) {},
/// );
/// ```
@internal
final class CoachMarkBubble extends StatelessWidget {
  /// [step] と閉じるコールバックを受け取る。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkBubble(step: step, onDismiss: (_) {});
  /// ```
  const CoachMarkBubble({
    required this.step,
    required this.onDismiss,
    super.key,
  });

  /// 外周 padding。
  static const double padding = 8;

  /// 表示内容。
  final CoachMarkStep step;

  /// 閉じたときの理由通知。
  final ValueChanged<CoachMarkDismissReason> onDismiss;

  /// 文言と主／副ボタンを描く。
  ///
  /// Example:
  /// ```dart
  /// bubble.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final secondary = step.secondaryLabel;
    final maxWidth = MediaQuery.sizeOf(context).width - padding * 2;
    return Semantics(
      label: step.title,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(padding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.theme.colors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: padding,
                children: [
                  Text(step.title),
                  Text(step.body),
                  if (secondary != null)
                    FButton(
                      variant: .secondary,
                      onPress: () =>
                          onDismiss(CoachMarkDismissReason.secondary),
                      child: Text(secondary),
                    ),
                  FButton(
                    onPress: () => onDismiss(CoachMarkDismissReason.primary),
                    child: Text(step.primaryLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
