import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show BlendMode, ColorFilter, ImageFilter;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'coach_mark_bubble.dart';
import 'coach_mark_dismiss_reason.dart';
import 'coach_mark_providers.dart';
import 'coach_mark_step.dart';

/// コーチマークの表示／破棄（`tutorial_coach_mark` 経由）。
///
/// Example:
/// ```dart
/// await CoachMarkLauncher.show(
///   context,
///   step: CoachMarkStep(
///     targetId: CoachMarkTargetId.homePeriodTotals,
///     title: 't',
///     body: 'b',
///     primaryLabel: '次へ',
///   ),
/// );
/// ```
final class CoachMarkLauncher {
  /// 静的 API のみのため生成しない。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkLauncher.show;
  /// ```
  const CoachMarkLauncher._();

  /// ライブラリ top／bottom 配置で吹き出しが収まるための最小高さ。
  @visibleForTesting
  static const double minContentHeight = 160;

  /// 吹き出しと穴・画面端のあいだの余白。
  static const double _gap = 8;

  /// [TutorialCoachMark] の focus padding（配置計算と揃える）。
  static const double _focusPad = 4;

  /// 表示中のコントローラ。
  static TutorialCoachMark? _active;

  /// 表示中の完了待ち。
  static Completer<CoachMarkDismissReason>? _activeCompleter;

  /// 既存表示があれば先に破棄してから [step] を載せる。
  ///
  /// ルート [Overlay] へ載せる。画面から [Navigator] を直接呼ばない。
  ///
  /// Example:
  /// ```dart
  /// await CoachMarkLauncher.show(context, step: step);
  /// ```
  static Future<CoachMarkDismissReason> show(
    BuildContext context, {
    required CoachMarkStep step,
  }) {
    dismissActive();
    final completer = Completer<CoachMarkDismissReason>();
    _activeCompleter = completer;

    final container = ProviderScope.containerOf(context);
    final registry = container.read(CoachMarkProviders.registry);
    final size = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.paddingOf(context);
    final hole = registry.rectFor(step.targetId, context);
    // Overlay 上でも吹き出しがテーマを読めるよう、呼び出し側の FTheme を運ぶ。
    final theme = context.theme;

    void complete(CoachMarkDismissReason reason) {
      _finishActive(reason);
    }

    // keyTarget ではなく表示時点の矩形を渡す（root Overlay でも座標解決できる）。
    final fallback = TargetPosition(
      Size(size.width * 0.6, 48),
      Offset(size.width * 0.2, size.height * 0.4),
    );
    final position = hole == null
        ? fallback
        : TargetPosition(hole.size, hole.topLeft);

    final placement = resolveContentPlacement(
      hole: hole,
      screenSize: size,
      safePadding: safePadding,
    );

    final target = TargetFocus(
      identify: step.targetId.name,
      targetPosition: position,
      shape: ShapeLightFocus.RRect,
      radius: 8,
      paddingFocus: _focusPad,
      enableOverlayTab: false,
      // 穴タップは主ボタン（閉じる／次へ）と同じ primary 完了にする。
      enableTargetTab: true,
      contents: [
        TargetContent(
          align: placement.align,
          customPosition: placement.customPosition,
          padding: EdgeInsets.zero,
          child: FTheme(
            data: theme,
            child: CoachMarkBubble(step: step, onDismiss: complete),
          ),
        ),
      ],
    );

    late final TutorialCoachMark tutorial;
    tutorial = TutorialCoachMark(
      targets: [target],
      hideSkip: true,
      pulseEnable: false,
      // 影色は imageFilter の ColorFilter（Forui ダイアログ障壁と同系）に任せる。
      opacityShadow: 0,
      // Forui `FDialogRouteStyle.defaultBarrierFilter` の定常値（sigma 5 + barrier）。
      imageFilter: ImageFilter.compose(
        outer: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        inner: ColorFilter.mode(theme.colors.barrier, BlendMode.srcOver),
      ),
      paddingFocus: _focusPad,
      focusAnimationDuration: const Duration(milliseconds: 300),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      // OS 戻るをライブラリ側で無効化する。
      disableBackButton: true,
      onFinish: () {
        // 旧インスタンスの finish が、次の表示の Completer を誤って完了させない。
        if (!identical(_active, tutorial)) {
          return;
        }
        // finish() 経由（穴タップ含む）も主ボタンと同じく removeRoute 後始末を待つ。
        // 同期 complete だと直後の連鎖 show の Navigator.push と競合する。
        _finishActive(CoachMarkDismissReason.primary);
      },
    );
    _active = tutorial;
    tutorial.show(context: context, rootOverlay: true);

    return completer.future;
  }

  /// 表示中なら即時破棄する（再表示タイル・文脈割り込み用）。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkLauncher.dismissActive();
  /// ```
  static void dismissActive() {
    _finishActive(CoachMarkDismissReason.forced);
  }

  /// 穴と画面サイズから吹き出しの [ContentAlign] を決める（余白十分時）。
  ///
  /// 大きな穴で画面外へ出る場合は [resolveContentPlacement] を使う。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkLauncher.contentAlignFor(hole: null, screenSize: Size.zero);
  /// ```
  @visibleForTesting
  static ContentAlign contentAlignFor({
    required Rect? hole,
    required Size screenSize,
  }) {
    return resolveContentPlacement(hole: hole, screenSize: screenSize).align;
  }

  /// 穴の外に十分な余白があれば top／bottom、なければ画面内へ custom 固定する。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkLauncher.resolveContentPlacement(
  ///   hole: Rect.fromLTWH(0, 0, 100, 400),
  ///   screenSize: Size(360, 640),
  /// );
  /// ```
  @visibleForTesting
  static ({ContentAlign align, CustomTargetContentPosition? customPosition})
  resolveContentPlacement({
    required Rect? hole,
    required Size screenSize,
    EdgeInsets safePadding = EdgeInsets.zero,
  }) {
    if (hole == null || screenSize.height <= 0) {
      return (align: ContentAlign.bottom, customPosition: null);
    }

    final centerY = hole.center.dy;
    final haloH = hole.height * 0.6 + _focusPad;
    final spaceIfBottom =
        screenSize.height - (centerY + haloH) - safePadding.bottom;
    final topBottomInset = haloH + (screenSize.height - centerY);
    final spaceIfTop = screenSize.height - topBottomInset - safePadding.top;
    final preferTop = centerY > screenSize.height * 0.55;

    if (preferTop) {
      if (spaceIfTop >= minContentHeight) {
        return (align: ContentAlign.top, customPosition: null);
      }
      if (spaceIfBottom >= minContentHeight) {
        return (align: ContentAlign.bottom, customPosition: null);
      }
    } else {
      if (spaceIfBottom >= minContentHeight) {
        return (align: ContentAlign.bottom, customPosition: null);
      }
      if (spaceIfTop >= minContentHeight) {
        return (align: ContentAlign.top, customPosition: null);
      }
    }

    final spaceAbove = math.max(0.0, hole.top - safePadding.top);
    final spaceBelow = math.max(
      0.0,
      screenSize.height - hole.bottom - safePadding.bottom,
    );

    if (spaceBelow >= minContentHeight) {
      return (
        align: ContentAlign.custom,
        customPosition: CustomTargetContentPosition(
          left: 0,
          right: 0,
          top: hole.bottom + _gap,
        ),
      );
    }
    if (spaceAbove >= minContentHeight) {
      return (
        align: ContentAlign.custom,
        customPosition: CustomTargetContentPosition(
          left: 0,
          right: 0,
          bottom: screenSize.height - hole.top + _gap,
        ),
      );
    }

    // 穴がほぼ全画面: 端帯に載せてボタン操作を確保する。
    if (spaceAbove >= spaceBelow) {
      return (
        align: ContentAlign.custom,
        customPosition: CustomTargetContentPosition(
          left: 0,
          right: 0,
          top: safePadding.top + _gap,
        ),
      );
    }
    return (
      align: ContentAlign.custom,
      customPosition: CustomTargetContentPosition(
        left: 0,
        right: 0,
        bottom: safePadding.bottom + _gap,
      ),
    );
  }

  /// 完了理由を確定し、オーバーレイを外す。
  ///
  /// 未挿入時は上流の `Future.delayed(Duration.zero)` のあとに外す。
  /// 完了通知は [removeOverlayEntry]（`disableBackButton` の `removeRoute`）の
  /// Navigator / Focus 後始末より後にし、直後の再 [show] の `push` と競合させない。
  ///
  /// Example:
  /// ```dart
  /// _finishActive(CoachMarkDismissReason.primary);
  /// ```
  static void _finishActive(CoachMarkDismissReason reason) {
    final completer = _activeCompleter;
    final tutorial = _active;
    _activeCompleter = null;
    _active = null;

    void completeLater() {
      if (completer == null || completer.isCompleted) {
        return;
      }
      // removeRoute 同期処理のあとに積まれる Focus 微タスクより後へ回す。
      // 同期 complete だと呼び出し側の連鎖 show が Navigator.push と競合し、
      // 目標設定文脈の 3 手やホーム段階連鎖などで次段階が出ない。
      scheduleMicrotask(() {
        if (!completer.isCompleted) {
          completer.complete(reason);
        }
      });
    }

    if (tutorial != null) {
      // 未挿入なら上流の Future.delayed(Duration.zero) のあとに外す。
      // 先に remove/closeHiddenView すると disableBackButton 経路が _contextTutorial! で落ちる。
      // 未挿入経路では遅延削除のあとで complete し、直後の再 show と競合させない。
      // 呼び出し元 Widget の dispose 中は Navigator 祖先が不安定なため失敗を握る。
      if (tutorial.isShowing) {
        _removeOverlayQuietly(tutorial);
        completeLater();
      } else {
        Future.delayed(Duration.zero, () {
          _removeOverlayQuietly(tutorial);
          completeLater();
        });
      }
      return;
    }
    completeLater();
  }

  /// [removeOverlayEntry] を試し、deactivate 済み context では失敗を握る。
  ///
  /// Example:
  /// ```dart
  /// _removeOverlayQuietly(tutorial);
  /// ```
  static void _removeOverlayQuietly(TutorialCoachMark tutorial) {
    try {
      tutorial.removeOverlayEntry();
    } on Object {
      // dispose 中の Navigator.of 失敗など。参照は呼び出し側で既に外している。
    }
  }

  /// [_active] / Completer 参照だけ消す（onFinish 用）。
  ///
  /// Example:
  /// ```dart
  /// _clearActiveRefs();
  /// ```
  static void _clearActiveRefs() {
    _active = null;
    _activeCompleter = null;
  }
}
