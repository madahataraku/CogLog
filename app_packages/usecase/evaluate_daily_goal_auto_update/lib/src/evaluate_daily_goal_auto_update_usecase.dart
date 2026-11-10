import 'package:riverpod/riverpod.dart';

import 'evaluate_daily_goal_auto_update_request.dart';
import 'evaluate_daily_goal_auto_update_result.dart';

/// 運動履歴変更後に目標の自動更新を判定・適用する。
///
/// Example:
/// ```dart
/// usecase.execute(
///   EvaluateDailyGoalAutoUpdateRequest(now: DateTime.timestamp()),
/// );
/// ```
abstract interface class EvaluateDailyGoalAutoUpdateUsecase {
  /// 未接続のときは失敗する注入点。
  static final provider = Provider<EvaluateDailyGoalAutoUpdateUsecase>(
    (ref) =>
        throw UnimplementedError('EvaluateDailyGoalAutoUpdateUsecase.provider'),
  );

  /// [request] に基づき連続達成を見て、条件を満たせば目標を上方修正する。
  ///
  /// 失敗しても例外は投げず [EvaluateDailyGoalAutoUpdateResult.applied] を false にする。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   EvaluateDailyGoalAutoUpdateRequest(now: DateTime.timestamp()),
  /// );
  /// ```
  Future<EvaluateDailyGoalAutoUpdateResult> execute(
    EvaluateDailyGoalAutoUpdateRequest request,
  );
}
