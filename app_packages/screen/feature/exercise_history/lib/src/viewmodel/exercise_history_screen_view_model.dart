import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';

import 'delegate/exercise_history_state_to_entity_delegate.dart';
import 'delegate/on_cold_start_delegate.dart';
import 'delegate/on_reload_selected_month_delegate.dart';
import 'delegate/on_retry_delegate.dart';
import 'delegate/on_select_month_delegate.dart';
import 'delegate/on_tap_day_delegate.dart';
import 'entity/exercise_history_screen_entity.dart';
import 'state/exercise_history_screen_state.dart';

part 'exercise_history_screen_view_model.action.dart';

/// 運動履歴カレンダーの状態と表示。
///
/// Example:
/// ```dart
/// ExerciseHistoryScreenViewModel.provider;
/// ```
@internal
final class ExerciseHistoryScreenViewModel {
  /// 月 Usecase と遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(ExerciseHistoryScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<ExerciseHistoryScreenViewModel>(
    (ref) {
      final now = DateTime.now();
      final result = ExerciseHistoryScreenViewModel._(
        state: MutableStateStream(
          ExerciseHistoryScreenState.initial(year: now.year, month: now.month),
        ),
        loadMonthUsecase: ref.watch(LoadExerciseHistoryMonthUsecase.provider),
        navigation: ref.watch(screenNavigationProvider),
        stateToEntity: const ExerciseHistoryStateToEntityDelegate(),
        clock: DateTime.now,
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      LoadExerciseHistoryMonthUsecase.provider,
      screenNavigationProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 月内全件の読み込み。
  @visibleForTesting
  final LoadExerciseHistoryMonthUsecase loadMonthUsecase;

  /// 詳細への遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State から表示用 Entity への変換。
  @visibleForTesting
  final ExerciseHistoryStateToEntityDelegate stateToEntity;

  /// 当月判定に使う時計。
  @visibleForTesting
  final DateTime Function() clock;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryScreenViewModel.provider;
  /// ```
  const ExerciseHistoryScreenViewModel._({
    required this.state,
    required this.loadMonthUsecase,
    required this.navigation,
    required this.stateToEntity,
    required this.clock,
  });

  /// 表示に使う文字列とフラグ。
  StateStream<ExerciseHistoryScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
