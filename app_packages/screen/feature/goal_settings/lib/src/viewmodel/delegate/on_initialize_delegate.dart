import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';

import '../state/goal_settings_screen_state.dart';

/// 一日あたり目標と自動更新設定を読み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadDailyGoalUsecase: loadDailyGoalUsecase,
/// ).execute();
/// ```
final class OnInitializeDelegate {
  /// [state] と [loadDailyGoalUsecase] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   loadDailyGoalUsecase: loadDailyGoalUsecase,
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.loadDailyGoalUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<GoalSettingsScreenState> state;

  /// 一日あたり目標の読み込み。
  final LoadDailyGoalUsecase loadDailyGoalUsecase;

  /// 保存済み目標と自動更新を読み、成功したら loaded にする。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    await state.updateWithLock((_, emitter) async {
      final result = await loadDailyGoalUsecase.execute(
        const LoadDailyGoalRequest(),
      );
      await emitter.emit(
        GoalSettingsScreenState(
          loaded: true,
          goal: result.goal,
          autoUpdateEnabled: result.autoUpdate.enabled,
          autoUpdateLevel: result.autoUpdate.level,
        ),
      );
    });
  }
}
