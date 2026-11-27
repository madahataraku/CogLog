import 'dart:math' as math;

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

  /// 内容外周と要素間の余白（確認ダイアログなどと同値の 16）。
  static const double padding = 16;

  /// 表示内容。
  final CoachMarkStep step;

  /// 閉じたときの理由通知。
  final ValueChanged<CoachMarkDismissReason> onDismiss;

  /// 主ボタン 1 個分の概算高さ（余白込み。帯が狭いとき本文側の上限計算に使う）。
  static const double _primaryButtonBlock = 48;

  /// 文言と主／副ボタンを描く。
  ///
  /// 親（SafeArea 内の Positioned 帯）の高さ上限と画面高さの約半分の小さい方に収める。
  /// 本文だけをスクロールし、主／副ボタンは常に見える位置に残す。
  ///
  /// Example:
  /// ```dart
  /// bubble.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final secondary = step.secondaryLabel;
    final screen = MediaQuery.sizeOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = math.min(
          screen.width - padding * 2,
          constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : screen.width - padding * 2,
        );
        final parentMax = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : screen.height * 0.45;
        final outerMax = math.max(
          0.0,
          math.min(screen.height * 0.45, parentMax) - padding * 2,
        );
        // 枠内余白・ボタン列を除いた本文の上限。
        final buttonBlock =
            _primaryButtonBlock +
            (secondary != null ? _primaryButtonBlock + padding : 0) +
            padding;
        final textMax = math.max(0.0, outerMax - padding * 2 - buttonBlock);
        return Semantics(
          label: step.title,
          liveRegion: true,
          child: Padding(
            padding: const EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: outerMax,
              ),
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
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: textMax),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: padding,
                            children: [Text(step.title), Text(step.body)],
                          ),
                        ),
                      ),
                      if (secondary != null)
                        FButton(
                          variant: .secondary,
                          onPress: () =>
                              onDismiss(CoachMarkDismissReason.secondary),
                          child: Text(secondary),
                        ),
                      FButton(
                        onPress: () =>
                            onDismiss(CoachMarkDismissReason.primary),
                        child: Text(step.primaryLabel),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
