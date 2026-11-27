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

  /// 主ボタン 1 個分の概算高さ（帯が狭いとき本文／全体スクロールの判定に使う）。
  static const double _primaryButtonBlock = 48;

  /// 文言と主／副ボタンを描く。
  ///
  /// 親帯の高さ上限と画面高さの約半分の小さい方に収める。
  /// 帯に余裕があれば本文だけスクロールしてボタンを残し、足りなければ全体をスクロールする。
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
        final buttonBlock =
            _primaryButtonBlock +
            (secondary != null ? _primaryButtonBlock + padding : 0) +
            padding;
        // ボタン列＋枠内余白を残せるときだけ本文固定スクロール。足りなければ全体スクロール。
        final pinButtons = outerMax >= buttonBlock + padding * 2;
        final textMax = pinButtons
            ? math.max(0.0, outerMax - padding * 2 - buttonBlock)
            : 0.0;

        final buttons = <Widget>[
          if (secondary != null)
            FButton(
              variant: .secondary,
              onPress: () => onDismiss(CoachMarkDismissReason.secondary),
              child: Text(secondary),
            ),
          FButton(
            onPress: () => onDismiss(CoachMarkDismissReason.primary),
            child: Text(step.primaryLabel),
          ),
        ];

        final Widget body = pinButtons
            ? Column(
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
                  ...buttons,
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: padding,
                  children: [Text(step.title), Text(step.body), ...buttons],
                ),
              );

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
                  child: body,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
