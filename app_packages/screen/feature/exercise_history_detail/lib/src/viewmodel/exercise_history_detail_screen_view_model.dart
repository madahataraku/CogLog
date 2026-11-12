import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_delete_exercise_history/usecase_delete_exercise_history.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

import 'delegate/exercise_history_detail_state_to_entity_delegate.dart';
import 'delegate/on_back_delegate.dart';
import 'delegate/on_delete_delegate.dart';
import 'delegate/on_edit_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_page_changed_delegate.dart';
import 'delegate/on_retry_delegate.dart';
import 'entity/exercise_history_detail_screen_entity.dart';
import 'state/exercise_history_detail_screen_state.dart';

part 'exercise_history_detail_screen_view_model.action.dart';

/// 運動履歴詳細の状態と表示。
///
/// Example:
/// ```dart
/// ExerciseHistoryDetailScreenViewModel.provider;
/// ```
@internal
final class ExerciseHistoryDetailScreenViewModel {
  /// 詳細・同一日 Usecase と遷移を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(ExerciseHistoryDetailScreenViewModel.provider);
  /// ```
  static final provider =
      Provider.autoDispose<ExerciseHistoryDetailScreenViewModel>(
        (ref) {
          final result = ExerciseHistoryDetailScreenViewModel._(
            state: MutableStateStream(
              ExerciseHistoryDetailScreenState.initial(id: ''),
            ),
            loadDetailUsecase: ref.watch(
              LoadExerciseHistoryDetailUsecase.provider,
            ),
            loadSameDayUsecase: ref.watch(
              LoadExerciseHistoriesForSameRecordedDayUsecase.provider,
            ),
            deleteUsecase: ref.watch(DeleteExerciseHistoryUsecase.provider),
            navigation: ref.watch(screenNavigationProvider),
            stateToEntity: const ExerciseHistoryDetailStateToEntityDelegate(),
          );
          ref.onDispose(() {
            unawaited(result._close());
          });
          return result;
        },
        dependencies: [
          LoadExerciseHistoryDetailUsecase.provider,
          LoadExerciseHistoriesForSameRecordedDayUsecase.provider,
          DeleteExerciseHistoryUsecase.provider,
          screenNavigationProvider,
        ],
      );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<ExerciseHistoryDetailScreenState> state;

  /// 詳細の読み込み。
  @visibleForTesting
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// 同一記録日 ID 列の読み込み。
  @visibleForTesting
  final LoadExerciseHistoriesForSameRecordedDayUsecase loadSameDayUsecase;

  /// 運動履歴の削除。
  @visibleForTesting
  final DeleteExerciseHistoryUsecase deleteUsecase;

  /// 戻る・編集遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// State から表示用 Entity への変換。
  @visibleForTesting
  final ExerciseHistoryDetailStateToEntityDelegate stateToEntity;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryDetailScreenViewModel.provider;
  /// ```
  const ExerciseHistoryDetailScreenViewModel._({
    required this.state,
    required this.loadDetailUsecase,
    required this.loadSameDayUsecase,
    required this.deleteUsecase,
    required this.navigation,
    required this.stateToEntity,
  });

  /// 表示に使う文字列とフラグ。
  StateStream<ExerciseHistoryDetailScreenEntity> get entity =>
      state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
