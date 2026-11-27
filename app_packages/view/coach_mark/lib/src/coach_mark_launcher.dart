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
import 'coach_mark_target_id.dart';

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

  /// 既定の穴角丸。
  static const double _defaultFocusRadius = 8;

  /// アチーブメント行枠に合わせた穴角丸。
  static const double _achievementFocusRadius = 12;

  /// [id] に応じた穴の角丸半径。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkLauncher.focusRadiusFor(CoachMarkTargetId.achievementList);
  /// ```
  @visibleForTesting
  static double focusRadiusFor(CoachMarkTargetId id) {
    return id == CoachMarkTargetId.achievementList
        ? _achievementFocusRadius
        : _defaultFocusRadius;
  }

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

    // キーが生きていれば keyTarget で毎フレーム再計測し、なければ矩形スナップショット／中央。
    // root Overlay 基準の rectFor と keyTarget(rootOverlay: true) は同系。
    final fallback = TargetPosition(
      Size(size.width * 0.6, 48),
      Offset(size.width * 0.2, size.height * 0.4),
    );
    final key = registry.keyFor(step.targetId);
    final keyReady = shouldUseKeyTarget(key: key, hole: hole);
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
      keyTarget: keyReady ? key : null,
      targetPosition: position,
      shape: ShapeLightFocus.RRect,
      radius: focusRadiusFor(step.targetId),
      paddingFocus: _focusPad,
      enableOverlayTab: false,
      // 穴タップは主ボタン（閉じる／次へ）と同じ primary 完了にする。
      enableTargetTab: true,
      contents: [
        TargetContent(
          align: placement.align,
          customPosition: placement.customPosition,
          padding: EdgeInsets.zero,
          // Positioned(top+bottom) は高さタイト拘束になるため Align で緩め、
          // 吹き出しは内容サイズ（上限あり）に縮み穴を覆わない。
          child: FTheme(
            data: theme,
            child: Align(
              alignment: placement.bubbleAlignment,
              child: CoachMarkBubble(step: step, onDismiss: complete),
            ),
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

  /// 穴と画面サイズから吹き出しの [ContentAlign] を決める。
  ///
  /// 実装は常に [ContentAlign.custom]（SafeArea 帯）。詳細は [resolveContentPlacement]。
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

  /// 登録キーが生きて矩形も取れるとき [TargetFocus.keyTarget] を使うか。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkLauncher.shouldUseKeyTarget(key: key, hole: rect);
  /// ```
  @visibleForTesting
  static bool shouldUseKeyTarget({
    required GlobalKey? key,
    required Rect? hole,
  }) {
    return key?.currentContext != null && hole != null;
  }

  /// 穴の上下どちらに載せるかを決め、常に SafeArea 内の custom 帯へ固定する。
  ///
  /// `tutorial_coach_mark` の ContentAlign.top／bottom は高さ上限がなく、
  /// custom で top か bottom だけ指定すると吹き出しが SafeArea 外へ伸びる。
  /// そのため top と bottom の両方を指定し、Positioned の帯内に収める。
  /// [bubbleAlignment] は帯内で吹き出しを穴寄り（または下端）へ寄せる。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkLauncher.resolveContentPlacement(
  ///   hole: Rect.fromLTWH(0, 0, 100, 400),
  ///   screenSize: Size(360, 640),
  /// );
  /// ```
  @visibleForTesting
  static ({
    ContentAlign align,
    CustomTargetContentPosition? customPosition,
    AlignmentGeometry bubbleAlignment,
  })
  resolveContentPlacement({
    required Rect? hole,
    required Size screenSize,
    EdgeInsets safePadding = EdgeInsets.zero,
  }) {
    final bandTop = safePadding.top + _gap;
    final bandBottom = safePadding.bottom + _gap;
    final bandLeft = safePadding.left + _gap;
    final bandRight = safePadding.right + _gap;

    CustomTargetContentPosition safeBand({
      required double top,
      required double bottom,
    }) {
      final clampedTop = math.max(
        bandTop,
        math.min(top, screenSize.height - bandBottom),
      );
      final clampedBottom = math.max(
        bandBottom,
        math.min(bottom, screenSize.height - clampedTop),
      );
      return CustomTargetContentPosition(
        left: bandLeft,
        right: bandRight,
        top: clampedTop,
        bottom: clampedBottom,
      );
    }

    if (hole == null || screenSize.height <= 0) {
      return (
        align: ContentAlign.custom,
        customPosition: safeBand(top: bandTop, bottom: bandBottom),
        bubbleAlignment: Alignment.bottomCenter,
      );
    }

    final preferTop = hole.center.dy > screenSize.height * 0.55;
    final spaceAbove = math.max(0.0, hole.top - bandTop);
    final spaceBelow = math.max(
      0.0,
      screenSize.height - hole.bottom - bandBottom,
    );

    // 穴がほぼ全画面で上下とも足りないときは、SafeArea 全体を帯にして操作を確保する。
    if (spaceAbove < minContentHeight && spaceBelow < minContentHeight) {
      return (
        align: ContentAlign.custom,
        customPosition: safeBand(top: bandTop, bottom: bandBottom),
        bubbleAlignment: Alignment.bottomCenter,
      );
    }

    final bool placeAbove;
    if (preferTop) {
      placeAbove = spaceAbove >= minContentHeight || spaceAbove >= spaceBelow;
    } else if (spaceBelow >= minContentHeight) {
      placeAbove = false;
    } else {
      placeAbove = true;
    }

    if (placeAbove) {
      // 穴の直上〜 SafeArea 上端。両方指定して帯内に収める。
      final bottomFromScreen =
          screenSize.height - math.max(hole.top - _gap, bandTop);
      return (
        align: ContentAlign.custom,
        customPosition: safeBand(top: bandTop, bottom: bottomFromScreen),
        bubbleAlignment: Alignment.bottomCenter,
      );
    }

    // 穴の直下〜 SafeArea 下端。
    return (
      align: ContentAlign.custom,
      customPosition: safeBand(
        top: math.min(hole.bottom + _gap, screenSize.height - bandBottom),
        bottom: bandBottom,
      ),
      bubbleAlignment: Alignment.topCenter,
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
}
