import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coach_mark_dismiss_reason.dart';
import 'coach_mark_overlay.dart';
import 'coach_mark_providers.dart';
import 'coach_mark_step.dart';

/// コーチマークの表示／破棄。
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

  /// 表示中の Entry。
  static OverlayEntry? _activeEntry;

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

    final overlay = Overlay.of(context, rootOverlay: true);
    final container = ProviderScope.containerOf(context);
    final registry = container.read(CoachMarkProviders.registry);

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        final hole = registry.rectFor(step.targetId, overlayContext);
        return CoachMarkOverlay(
          step: step,
          hole: hole,
          onDismiss: (reason) {
            _removeActive(reason);
          },
        );
      },
    );
    _activeEntry = entry;
    overlay.insert(entry);
    return completer.future;
  }

  /// 表示中なら即時破棄する（再表示タイル・文脈割り込み用）。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkLauncher.dismissActive();
  /// ```
  static void dismissActive() {
    _removeActive(CoachMarkDismissReason.forced);
  }

  /// 表示中 Entry を外し Completer を完了する。
  ///
  /// Example:
  /// ```dart
  /// _removeActive(CoachMarkDismissReason.primary);
  /// ```
  static void _removeActive(CoachMarkDismissReason reason) {
    final entry = _activeEntry;
    final completer = _activeCompleter;
    _activeEntry = null;
    _activeCompleter = null;
    entry?.remove();
    if (completer != null && !completer.isCompleted) {
      completer.complete(reason);
    }
  }
}
