import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'coach_mark_providers.dart';
import 'coach_mark_registry.dart';
import 'coach_mark_target_id.dart';

/// 子を包み [id] を Registry へ登録する。
///
/// Example:
/// ```dart
/// CoachMarkTarget(
///   id: CoachMarkTargetId.navHome,
///   child: const SizedBox.shrink(),
/// );
/// ```
final class CoachMarkTarget extends ConsumerStatefulWidget {
  /// [id] でハイライト対象として [child] を登録する。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkTarget(
  ///   id: CoachMarkTargetId.homePeriodTotals,
  ///   child: const SizedBox.shrink(),
  /// );
  /// ```
  const CoachMarkTarget({required this.id, required this.child, super.key});

  /// ハイライト対象の識別子。
  final CoachMarkTargetId id;

  /// 包む子。
  final Widget child;

  /// Registry 登録を持つ [State] を返す。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkTarget(
  ///   id: CoachMarkTargetId.navHome,
  ///   child: const SizedBox.shrink(),
  /// ).createState();
  /// ```
  @override
  ConsumerState<CoachMarkTarget> createState() => _CoachMarkTargetState();
}

/// [CoachMarkTarget] の登録ライフサイクルを担う。
///
/// Example:
/// ```dart
/// _CoachMarkTargetState();
/// ```
final class _CoachMarkTargetState extends ConsumerState<CoachMarkTarget> {
  /// 矩形取得用キー。
  final GlobalKey _key = GlobalKey();

  /// dispose 時に使う台帳（ref 失効前に保持）。
  CoachMarkRegistry? _registry;

  /// Provider から台帳を取り [id] を登録する。
  ///
  /// Example:
  /// ```dart
  /// state.didChangeDependencies();
  /// ```
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final registry = ref.read(CoachMarkProviders.registry);
    _registry = registry;
    registry.register(widget.id, _key);
  }

  /// [id] が変わったときだけ付け替える。
  ///
  /// Example:
  /// ```dart
  /// state.didUpdateWidget(oldWidget);
  /// ```
  @override
  void didUpdateWidget(covariant CoachMarkTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      final registry = ref.read(CoachMarkProviders.registry);
      _registry?.unregister(oldWidget.id, _key);
      registry.register(widget.id, _key);
      _registry = registry;
    }
  }

  /// 台帳から外す。
  ///
  /// Example:
  /// ```dart
  /// state.dispose();
  /// ```
  @override
  void dispose() {
    _registry?.unregister(widget.id, _key);
    super.dispose();
  }

  /// [GlobalKey] 付きで子を描く。
  ///
  /// Example:
  /// ```dart
  /// state.build(context);
  /// ```
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: _key, child: widget.child);
  }
}
