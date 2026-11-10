import 'package:riverpod/riverpod.dart';

import 'evaluate_achievements_request.dart';
import 'evaluate_achievements_result.dart';

/// 運動履歴からアチーブメントを評価し、新規充足分を永続化する。
///
/// Example:
/// ```dart
/// usecase.execute(
///   EvaluateAchievementsRequest(
///     now: DateTime.timestamp(),
///     emitNotifications: true,
///   ),
/// );
/// ```
abstract interface class EvaluateAchievementsUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<EvaluateAchievementsUsecase>(
    (ref) => throw UnimplementedError('EvaluateAchievementsUsecase.provider'),
  );

  /// [request] に基づき達成状況を見て、未獲得の充足分を merge する。
  ///
  /// 永続 unlocks が空の最初の評価は初回遡及とし、[emitNotifications] が true
  /// でも [EvaluateAchievementsResult.newlyUnlocked] は空にする。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   EvaluateAchievementsRequest(
  ///     now: DateTime.timestamp(),
  ///     emitNotifications: true,
  ///   ),
  /// );
  /// ```
  Future<EvaluateAchievementsResult> execute(
    EvaluateAchievementsRequest request,
  );
}
