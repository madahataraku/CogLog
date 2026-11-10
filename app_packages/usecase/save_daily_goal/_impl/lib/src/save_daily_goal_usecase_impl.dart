import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';

/// 一日あたり目標と自動更新設定を Repository に渡す。
///
/// Example:
/// ```dart
/// SaveDailyGoalUsecaseImpl(goals: goals).execute(
///   SaveDailyGoalRequest(
///     goal: DailyGoal.unset,
///     autoUpdateEnabled: false,
///     autoUpdateLevel: DailyGoalAutoUpdateLevel.normal,
///     now: DateTime(2026, 11, 5),
///   ),
/// );
/// ```
final class SaveDailyGoalUsecaseImpl implements SaveDailyGoalUsecase {
  /// [goals] へ書く実装を作る。
  ///
  /// Example:
  /// ```dart
  /// SaveDailyGoalUsecaseImpl(goals: goals);
  /// ```
  const SaveDailyGoalUsecaseImpl({required this.goals});

  /// 一日あたり目標の保存先。
  final DailyGoalRepository goals;

  /// [request] の目標と自動更新設定を書き、同じ値を返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   SaveDailyGoalRequest(
  ///     goal: DailyGoal.unset,
  ///     autoUpdateEnabled: false,
  ///     autoUpdateLevel: DailyGoalAutoUpdateLevel.normal,
  ///     now: DateTime.timestamp(),
  ///   ),
  /// );
  /// ```
  @override
  Future<SaveDailyGoalResult> execute(SaveDailyGoalRequest request) async {
    final previousGoal = await goals.read();
    final previousSettings = await goals.readAutoUpdateSettings();
    final local = request.now.toLocal();
    final today = DateTime(local.year, local.month, local.day);

    var next = previousSettings.copyWith(level: request.autoUpdateLevel);
    if (!previousSettings.enabled && request.autoUpdateEnabled) {
      next = next.copyWith(enabled: true, enabledOnLocalDate: today);
    } else if (previousSettings.enabled && !request.autoUpdateEnabled) {
      next = next.copyWith(
        enabled: false,
        clearEnabledOnLocalDate: true,
        clearLastAppliedLocalDate: true,
        clearStreakEpochLocalDate: true,
      );
    } else {
      next = next.copyWith(enabled: request.autoUpdateEnabled);
    }

    if (!previousGoal.sameAs(request.goal)) {
      next = next.copyWith(streakEpochLocalDate: today);
    }

    // 設定を先に書く。目標の書き込みが失敗しても起算日は安全側に進む。
    await goals.writeAutoUpdateSettings(next);
    await goals.write(request.goal);
    return SaveDailyGoalResult(goal: request.goal, autoUpdate: next);
  }
}
