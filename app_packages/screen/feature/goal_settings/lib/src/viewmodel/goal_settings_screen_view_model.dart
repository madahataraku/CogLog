import 'dart:async';

import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';

import 'delegate/goal_settings_state_to_entity_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_save_delegate.dart';
import 'entity/goal_settings_screen_entity.dart';
import 'state/goal_settings_screen_state.dart';

part 'goal_settings_screen_view_model.action.dart';

/// 目標設定画面の状態と表示。
///
/// 可変な値は [state] だけが持つ。編集下書きは持たない。
///
/// Example:
/// ```dart
/// GoalSettingsScreenViewModel.provider;
/// ```
@internal
final class GoalSettingsScreenViewModel {
  /// 読み込みと保存の Usecase を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(GoalSettingsScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<GoalSettingsScreenViewModel>(
    (ref) {
      final result = GoalSettingsScreenViewModel._(
        state: MutableStateStream(GoalSettingsScreenState.initial),
        loadDailyGoalUsecase: ref.watch(LoadDailyGoalUsecase.provider),
        saveDailyGoalUsecase: ref.watch(SaveDailyGoalUsecase.provider),
        stateToEntity: const GoalSettingsStateToEntityDelegate(),
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      LoadDailyGoalUsecase.provider,
      SaveDailyGoalUsecase.provider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<GoalSettingsScreenState> state;

  /// 一日あたり目標の読み込み。
  @visibleForTesting
  final LoadDailyGoalUsecase loadDailyGoalUsecase;

  /// 一日あたり目標の保存。
  @visibleForTesting
  final SaveDailyGoalUsecase saveDailyGoalUsecase;

  /// State から入力欄の初期文字列への変換。
  @visibleForTesting
  final GoalSettingsStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// GoalSettingsScreenViewModel.provider;
  /// ```
  const GoalSettingsScreenViewModel._({
    required this.state,
    required this.loadDailyGoalUsecase,
    required this.saveDailyGoalUsecase,
    required this.stateToEntity,
  });

  /// 表示に使う文字列。
  StateStream<GoalSettingsScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
