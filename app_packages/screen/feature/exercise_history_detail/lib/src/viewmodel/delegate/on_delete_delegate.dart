import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_delete_exercise_history/usecase_delete_exercise_history.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

import '../state/exercise_history_detail_screen_state.dart';
import 'on_initialize_delegate.dart';

/// 確認済みの削除を実行し、同一日の残りへ移るかカレンダーへ戻る。
///
/// 削除前に保持した [ExerciseHistoryDetailScreenState.sameDayIds] から残りを決める。
/// 残りがあるときは push せず再読込する。
///
/// Example:
/// ```dart
/// OnDeleteDelegate(
///   state: state,
///   deleteUsecase: deleteUsecase,
///   loadDetailUsecase: loadDetailUsecase,
///   loadSameDayUsecase: loadSameDayUsecase,
///   navigation: navigation,
/// ).execute();
/// ```
final class OnDeleteDelegate {
  /// 削除と遷移に必要な依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnDeleteDelegate(
  ///   state: state,
  ///   deleteUsecase: deleteUsecase,
  ///   loadDetailUsecase: loadDetailUsecase,
  ///   loadSameDayUsecase: loadSameDayUsecase,
  ///   navigation: navigation,
  /// );
  /// ```
  const OnDeleteDelegate({
    required this.state,
    required this.deleteUsecase,
    required this.loadDetailUsecase,
    required this.loadSameDayUsecase,
    required this.navigation,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryDetailScreenState> state;

  /// 運動履歴の削除。
  final DeleteExerciseHistoryUsecase deleteUsecase;

  /// 詳細の読み込み。
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// 同一記録日 ID 列の読み込み。
  final LoadExerciseHistoriesForSameRecordedDayUsecase loadSameDayUsecase;

  /// カレンダーへの戻る遷移。
  final ScreenNavigation navigation;

  /// 現在件を削除し、残りがあれば先頭を再表示、無ければ pop する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    late final String currentId;
    late final List<String> priorIds;
    late final String? healthId;
    final shouldDelete = await state.updateWithLock((current, emitter) async {
      if (current.deleting || current.editing || current.history == null) {
        return false;
      }
      currentId = current.history!.id;
      priorIds = List<String>.of(current.sameDayIds);
      healthId = current.history!.healthWorkoutId;
      await emitter.emit(
        current.copyWith(deleting: true, clearActionError: true),
      );
      return true;
    });
    if (!shouldDelete) {
      return;
    }

    try {
      final result = await deleteUsecase.execute(
        DeleteExerciseHistoryRequest(id: currentId, healthWorkoutId: healthId),
      );
      if (result.outcome != DeleteExerciseHistoryOutcome.success) {
        await state.updateWithLock((current, emitter) async {
          await emitter.emit(
            current.copyWith(deleting: false, actionError: true),
          );
        });
        return;
      }
    } on Object {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(
          current.copyWith(deleting: false, actionError: true),
        );
      });
      return;
    }

    final remaining = priorIds.where((id) => id != currentId).toList();
    if (remaining.isEmpty) {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(current.copyWith(deleting: false));
      });
      navigation.pop();
      return;
    }

    await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(deleting: false));
    });
    await OnInitializeDelegate(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
      loadSameDayUsecase: loadSameDayUsecase,
    ).execute(id: remaining.first);
  }
}
