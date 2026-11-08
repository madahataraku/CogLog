import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_page/usecase_load_exercise_history_page.dart';

import 'delegate/exercise_history_state_to_entity_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_load_more_delegate.dart';
import 'delegate/on_refresh_delegate.dart';
import 'delegate/on_retry_delegate.dart';
import 'delegate/on_select_month_delegate.dart';
import 'delegate/on_tap_item_delegate.dart';
import 'entity/exercise_history_screen_entity.dart';
import 'state/exercise_history_screen_state.dart';

part 'exercise_history_screen_view_model.action.dart';

/// 運動履歴一覧の状態と表示。
///
/// Example:
/// ```dart
/// ExerciseHistoryScreenViewModel.provider;
/// ```
@internal
final class ExerciseHistoryScreenViewModel {
  /// 一覧 Usecase と遷移を注入して作る。
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
        loadPageUsecase: ref.watch(LoadExerciseHistoryPageUsecase.provider),
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
      LoadExerciseHistoryPageUsecase.provider,
      screenNavigationProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<ExerciseHistoryScreenState> state;

  /// 一覧頁の読み込み。
  @visibleForTesting
  final LoadExerciseHistoryPageUsecase loadPageUsecase;

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
    required this.loadPageUsecase,
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
