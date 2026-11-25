import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:meta/meta.dart';

import 'coach_mark_dismiss_reason.dart';
import 'coach_mark_step.dart';

/// ディム＋穴＋吹き出しのコーチマーク本体。
///
/// Example:
/// ```dart
/// CoachMarkOverlay(
///   step: CoachMarkStep(
///     targetId: CoachMarkTargetId.homePeriodTotals,
///     title: 't',
///     body: 'b',
///     primaryLabel: '次へ',
///   ),
///   hole: null,
///   onDismiss: (_) {},
/// );
/// ```
@internal
final class CoachMarkOverlay extends StatelessWidget {
  /// [step] と任意の [hole]、閉じるコールバックを受け取る。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkOverlay(
  ///   step: step,
  ///   hole: Rect.fromLTWH(40, 120, 280, 80),
  ///   onDismiss: (_) {},
  /// );
  /// ```
  const CoachMarkOverlay({
    required this.step,
    required this.hole,
    required this.onDismiss,
    super.key,
  });

  /// 穴の角丸半径。
  static const double holeRadius = 8;

  /// 吹き出し外周 padding。
  static const double bubblePadding = 8;

  /// 表示内容。
  final CoachMarkStep step;

  /// ハイライト矩形。null なら穴なし。
  final Rect? hole;

  /// 閉じたときの理由通知。
  final ValueChanged<CoachMarkDismissReason> onDismiss;

  /// ディム・穴・吹き出しを重ねる。
  ///
  /// Example:
  /// ```dart
  /// overlay.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final hole = this.hole;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (step.blockSystemBack) {
          return;
        }
        onDismiss(CoachMarkDismissReason.systemBack);
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DimPainter(hole: hole, radius: holeRadius),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
              ),
            ),
          ),
          if (hole != null && !step.allowTargetInteraction)
            Positioned.fromRect(
              rect: hole,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {},
              ),
            ),
          _Bubble(
            step: step,
            hole: hole,
            screenSize: size,
            onDismiss: onDismiss,
          ),
        ],
      ),
    );
  }
}

/// 半透明ディム。穴は evenOdd で抜く。
final class _DimPainter extends CustomPainter {
  /// [hole] が null なら全画面ディム。
  ///
  /// Example:
  /// ```dart
  /// const _DimPainter(hole: null, radius: 8);
  /// ```
  const _DimPainter({required this.hole, required this.radius});

  /// ハイライト矩形。
  final Rect? hole;

  /// 角丸。
  final double radius;

  /// 全画面にディムを塗り、[hole] があれば角丸で抜く。
  ///
  /// Example:
  /// ```dart
  /// painter.paint(canvas, size);
  /// ```
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    final hole = this.hole;
    if (hole != null) {
      path.addRRect(RRect.fromRectAndRadius(hole, Radius.circular(radius)));
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x99000000)
        ..style = PaintingStyle.fill,
    );
  }

  /// [hole] か [radius] が変わったときだけ再描画する。
  ///
  /// Example:
  /// ```dart
  /// painter.shouldRepaint(oldPainter);
  /// ```
  @override
  bool shouldRepaint(covariant _DimPainter oldDelegate) =>
      oldDelegate.hole != hole || oldDelegate.radius != radius;
}

/// 吹き出し。穴の下（収まらなければ上）。穴なしは中央。
final class _Bubble extends StatelessWidget {
  /// [step] と配置用の [hole] / [screenSize] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// _Bubble(
  ///   step: step,
  ///   hole: null,
  ///   screenSize: Size.zero,
  ///   onDismiss: (_) {},
  /// );
  /// ```
  const _Bubble({
    required this.step,
    required this.hole,
    required this.screenSize,
    required this.onDismiss,
  });

  /// 表示内容。
  final CoachMarkStep step;

  /// ハイライト矩形。
  final Rect? hole;

  /// 画面サイズ。
  final Size screenSize;

  /// 閉じる通知。
  final ValueChanged<CoachMarkDismissReason> onDismiss;

  /// 文言と主／副ボタンを描き、穴基準で配置する。
  ///
  /// Example:
  /// ```dart
  /// bubble.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    final secondary = step.secondaryLabel;
    final bubble = Semantics(
      label: step.title,
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.all(CoachMarkOverlay.bubblePadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenSize.width - CoachMarkOverlay.bubblePadding * 2,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.theme.colors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(CoachMarkOverlay.bubblePadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: CoachMarkOverlay.bubblePadding,
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

    final hole = this.hole;
    if (hole == null) {
      return Center(child: bubble);
    }

    return CustomSingleChildLayout(
      delegate: _BubbleLayoutDelegate(hole: hole, screenSize: screenSize),
      child: bubble,
    );
  }
}

/// 吹き出しのレイアウト。穴下優先、収まらなければ上。
final class _BubbleLayoutDelegate extends SingleChildLayoutDelegate {
  /// [hole] と [screenSize] で配置を決める。
  ///
  /// Example:
  /// ```dart
  /// _BubbleLayoutDelegate(
  ///   hole: Rect.zero,
  ///   screenSize: Size.zero,
  /// );
  /// ```
  const _BubbleLayoutDelegate({required this.hole, required this.screenSize});

  /// ハイライト矩形。
  final Rect hole;

  /// 画面サイズ。
  final Size screenSize;

  /// 横は画面幅から padding を引いた上限。
  ///
  /// Example:
  /// ```dart
  /// delegate.getConstraintsForChild(const BoxConstraints());
  /// ```
  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints(
      maxWidth: screenSize.width - CoachMarkOverlay.bubblePadding * 2,
      maxHeight: screenSize.height,
    );
  }

  /// 穴下優先。収まらなければ上へ寄せ、左右は中央寄せで端にクランプ。
  ///
  /// Example:
  /// ```dart
  /// delegate.getPositionForChild(Size.zero, Size.zero);
  /// ```
  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final gap = CoachMarkOverlay.bubblePadding;
    var top = hole.bottom + gap;
    if (top + childSize.height > screenSize.height - gap) {
      top = hole.top - gap - childSize.height;
      if (top < gap) {
        top = gap;
      }
    }
    var left = hole.center.dx - childSize.width / 2;
    left = left.clamp(gap, screenSize.width - childSize.width - gap);
    return Offset(left, top);
  }

  /// [hole] か [screenSize] が変わったときだけ再配置する。
  ///
  /// Example:
  /// ```dart
  /// delegate.shouldRelayout(oldDelegate);
  /// ```
  @override
  bool shouldRelayout(covariant _BubbleLayoutDelegate oldDelegate) =>
      oldDelegate.hole != hole || oldDelegate.screenSize != screenSize;
}
