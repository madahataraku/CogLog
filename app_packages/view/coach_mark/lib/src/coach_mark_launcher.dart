import 'dart:async';

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

    final target = TargetFocus(
      identify: step.targetId.name,
      targetPosition: position,
      shape: ShapeLightFocus.RRect,
      radius: 8,
      paddingFocus: 4,
      enableOverlayTab: false,
      enableTargetTab: false,
      contents: [
        TargetContent(
          align: contentAlignFor(hole: hole, screenSize: size),
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
      opacityShadow: 0.6,
      paddingFocus: 4,
      focusAnimationDuration: const Duration(milliseconds: 300),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      // OS 戻るをライブラリ側で無効化する。
      disableBackButton: true,
      onFinish: () {
        // 旧インスタンスの finish が、次の表示の Completer を誤って完了させない。
        if (!identical(_active, tutorial)) {
          return;
        }
        // finish() 経由で外されたとき、未完了なら primary 相当として閉じる。
        final pending = _activeCompleter;
        if (pending != null && !pending.isCompleted) {
          pending.complete(CoachMarkDismissReason.primary);
        }
        _clearActiveRefs();
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

  /// 穴が画面下半分なら上、さもなくば下に吹き出しを置く。
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
    if (hole == null || screenSize.height <= 0) {
      return ContentAlign.bottom;
    }
    return hole.center.dy > screenSize.height * 0.55
        ? ContentAlign.top
        : ContentAlign.bottom;
  }

  /// 完了理由を確定し、オーバーレイを外す。
  ///
  /// 未挿入時は上流の `Future.delayed(Duration.zero)` のあとに外す。
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
    if (tutorial != null) {
      // 未挿入なら上流の Future.delayed(Duration.zero) のあとに外す。
      // 先に remove/closeHiddenView すると disableBackButton 経路が _contextTutorial! で落ちる。
      if (tutorial.isShowing) {
        tutorial.removeOverlayEntry();
      } else {
        Future.delayed(Duration.zero, () {
          tutorial.removeOverlayEntry();
        });
      }
    }
    if (completer != null && !completer.isCompleted) {
      completer.complete(reason);
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
