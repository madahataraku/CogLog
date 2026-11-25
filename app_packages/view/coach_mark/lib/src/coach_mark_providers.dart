import 'package:riverpod/riverpod.dart';

import 'coach_mark_registry.dart';

/// コーチマーク UI 用の Provider 束。
///
/// Example:
/// ```dart
/// CoachMarkProviders.registry;
/// ```
final class CoachMarkProviders {
  /// プロセス内のターゲット台帳。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(CoachMarkProviders.registry);
  /// ```
  static final registry = Provider<CoachMarkRegistry>((ref) {
    ref.keepAlive();
    return CoachMarkRegistry();
  });

  /// 静的 API のみのため生成しない。
  ///
  /// Example:
  /// ```dart
  /// CoachMarkProviders.registry;
  /// ```
  const CoachMarkProviders._();
}
