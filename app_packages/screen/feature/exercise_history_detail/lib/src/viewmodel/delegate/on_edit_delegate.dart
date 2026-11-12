import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_histories_for_same_recorded_day/usecase_load_exercise_histories_for_same_recorded_day.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

import '../state/exercise_history_detail_screen_state.dart';
import 'on_initialize_delegate.dart';

/// 編集画面を開き、保存結果に応じて詳細を再読込するかカレンダーへ戻る。
///
/// Example:
/// ```dart
/// OnEditDelegate(
///   state: state,
///   loadDetailUsecase: loadDetailUsecase,
///   loadSameDayUsecase: loadSameDayUsecase,
///   navigation: navigation,
/// ).execute();
/// ```
final class OnEditDelegate {
  /// 編集遷移と再読込に必要な依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnEditDelegate(
  ///   state: state,
  ///   loadDetailUsecase: loadDetailUsecase,
  ///   loadSameDayUsecase: loadSameDayUsecase,
  ///   navigation: navigation,
  /// );
  /// ```
  const OnEditDelegate({
    required this.state,
    required this.loadDetailUsecase,
    required this.loadSameDayUsecase,
    required this.navigation,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryDetailScreenState> state;

  /// 詳細の読み込み。
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// 同一記録日 ID 列の読み込み。
  final LoadExerciseHistoriesForSameRecordedDayUsecase loadSameDayUsecase;

  /// 編集画面と戻る遷移。
  final ScreenNavigation navigation;

  /// 現在件の編集画面を待ち、結果に応じて再読込またはカレンダーへ戻る。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    final current = state.state;
    if (current.deleting || current.editing || current.history == null) {
      return;
    }
    final currentId = current.history!.id;
    await state.updateWithLock((locked, emitter) async {
      if (locked.deleting || locked.editing || locked.history == null) {
        return;
      }
      await emitter.emit(
        locked.copyWith(editing: true, clearActionError: true),
      );
    });
    if (!state.state.editing) {
      return;
    }

    final result = await navigation.openExerciseHistoryEditAndWait(
      id: currentId,
    );

    await state.updateWithLock((locked, emitter) async {
      await emitter.emit(locked.copyWith(editing: false));
    });

    if (result == null || !result.saved) {
      return;
    }
    if (result.recordedLocalDayChanged) {
      navigation.pop();
      return;
    }
    await OnInitializeDelegate(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
      loadSameDayUsecase: loadSameDayUsecase,
    ).execute(id: currentId);
  }
}
