import 'package:data_repository_daily_goal/data_repository_daily_goal.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';

/// Repository から一日あたり目標を読む。
///
/// Example:
/// ```dart
/// LoadDailyGoalUsecaseImpl(goals: goals).execute(
///   const LoadDailyGoalRequest(),
/// );
/// ```
final class LoadDailyGoalUsecaseImpl implements LoadDailyGoalUsecase {
  /// [goals] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadDailyGoalUsecaseImpl(goals: goals);
  /// ```
  const LoadDailyGoalUsecaseImpl({required this.goals});

  /// 一日あたり目標の読み出し。
  final DailyGoalRepository goals;

  /// 保存が無ければ未設定を返す。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(const LoadDailyGoalRequest());
  /// ```
  @override
  Future<LoadDailyGoalResult> execute(LoadDailyGoalRequest request) async {
    final goal = await goals.read();
    final autoUpdate = await goals.readAutoUpdateSettings();
    return LoadDailyGoalResult(goal: goal, autoUpdate: autoUpdate);
  }
}
