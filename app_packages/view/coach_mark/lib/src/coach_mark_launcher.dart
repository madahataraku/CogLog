import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  /// 段階3 用の OS 戻る待ちルート（ライブラリの disableBack とは別）。
  static Route<void>? _systemBackRoute;

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
    final key = registry.keyFor(step.targetId);
    final size = MediaQuery.sizeOf(context);

    void complete(CoachMarkDismissReason reason) {
      _finishActive(reason);
    }

    final target = TargetFocus(
      identify: step.targetId.name,
      keyTarget: key,
      targetPosition: key == null
          ? TargetPosition(
              Size(size.width * 0.6, 48),
              Offset(size.width * 0.2, size.height * 0.4),
            )
          : null,
      shape: ShapeLightFocus.RRect,
      radius: 8,
      paddingFocus: 4,
      enableOverlayTab: false,
      enableTargetTab: false,
      enableTargetPassThrough: step.allowTargetInteraction,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          padding: EdgeInsets.zero,
          child: CoachMarkBubble(step: step, onDismiss: complete),
        ),
      ],
    );

    final tutorial = TutorialCoachMark(
      targets: [target],
      hideSkip: true,
      pulseEnable: false,
      opacityShadow: 0.6,
      paddingFocus: 4,
      focusAnimationDuration: const Duration(milliseconds: 300),
      unFocusAnimationDuration: const Duration(milliseconds: 200),
      // 段階3以外はライブラリ側で戻るを塞ぐ。段階3は自前ルートでスキップ扱い。
      disableBackButton: step.blockSystemBack,
      onFinish: () {
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

    if (!step.blockSystemBack) {
      _pushSystemBackRoute(context, complete);
    }

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

  /// 完了理由を確定し、オーバーレイと戻るルートを外す。
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
    _removeSystemBackRoute();
    if (tutorial != null && tutorial.isShowing) {
      // onFinish 内で completer を触らないよう先に外す。
      tutorial.removeOverlayEntry();
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
    _removeSystemBackRoute();
  }

  /// 段階3 向けに OS 戻るを握り、[complete] へ [CoachMarkDismissReason.systemBack] を渡す。
  ///
  /// Example:
  /// ```dart
  /// _pushSystemBackRoute(context, complete);
  /// ```
  static void _pushSystemBackRoute(
    BuildContext context,
    void Function(CoachMarkDismissReason) complete,
  ) {
    final navigator = Navigator.maybeOf(context, rootNavigator: true);
    if (navigator == null) {
      return;
    }
    final route = PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            complete(CoachMarkDismissReason.systemBack);
          },
          child: const SizedBox.shrink(),
        );
      },
    );
    _systemBackRoute = route;
    navigator.push(route);
  }

  /// 段階3 用ルートがあれば外す。
  ///
  /// Example:
  /// ```dart
  /// _removeSystemBackRoute();
  /// ```
  static void _removeSystemBackRoute() {
    final route = _systemBackRoute;
    _systemBackRoute = null;
    if (route == null || !route.isActive) {
      return;
    }
    final navigator = route.navigator;
    navigator?.removeRoute(route);
  }
}
