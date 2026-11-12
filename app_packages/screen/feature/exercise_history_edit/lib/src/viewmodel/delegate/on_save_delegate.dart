import 'package:meta/meta.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_update_exercise_history/usecase_update_exercise_history.dart';

import '../can_submit_exercise_history_edit.dart';
import '../state/exercise_history_edit_screen_state.dart';

/// 編集内容を更新し、成功時は [ExerciseHistoryEditPopResult] で閉じる。
///
/// Example:
/// ```dart
/// OnSaveDelegate(
///   state: state,
///   updateUsecase: updateUsecase,
///   navigation: navigation,
/// ).execute();
/// ```
@internal
final class OnSaveDelegate {
  /// 保存と遷移の依存を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSaveDelegate(
  ///   state: state,
  ///   updateUsecase: updateUsecase,
  ///   navigation: navigation,
  /// );
  /// ```
  const OnSaveDelegate({
    required this.state,
    required this.updateUsecase,
    required this.navigation,
  });

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryEditScreenState> state;

  /// 運動履歴の更新。
  final UpdateExerciseHistoryUsecase updateUsecase;

  /// 結果付きで戻る遷移。
  final ScreenNavigation navigation;

  /// 条件を満たせば更新し、成功時は pop する。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() async {
    UpdateExerciseHistoryRequest? request;
    await state.updateWithLock((current, emitter) async {
      if (current.saving ||
          current.reading ||
          current.inputsInvalid ||
          !canSubmitExerciseHistoryEdit(
            distanceKm: current.distanceKm,
            duration: current.duration,
            averageSpeedKmh: current.averageSpeedKmh,
            caloriesKcal: current.caloriesKcal,
            recordedAt: current.recordedAt,
            creationStartedAt: current.creationStartedAt,
            capturedAt: current.capturedAt,
          )) {
        return;
      }
      request = UpdateExerciseHistoryRequest(
        id: current.id,
        creationStartedAt: current.creationStartedAt!,
        capturedAt: current.capturedAt!,
        recordedAt: current.recordedAt!,
        distanceKm: current.distanceKm!,
        duration: current.duration!,
        caloriesKcal: current.caloriesKcal!,
        previousHealthWorkoutId: current.previousHealthWorkoutId,
        photoBytes: current.photoBytes,
      );
      await emitter.emit(current.copyWith(saving: true, saveError: false));
    });
    final pending = request;
    if (pending == null) {
      return;
    }

    try {
      final result = await updateUsecase.execute(pending);
      switch (result.outcome) {
        case UpdateExerciseHistoryOutcome.invalidInput:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(current.copyWith(saving: false));
          });
        case UpdateExerciseHistoryOutcome.saveFailed:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(
              current.copyWith(saving: false, saveError: true),
            );
          });
        case UpdateExerciseHistoryOutcome.success:
          await state.updateWithLock((current, emitter) async {
            await emitter.emit(
              current.copyWith(saving: false, dirty: false, saveError: false),
            );
          });
          navigation.popWithResult(
            ExerciseHistoryEditPopResult(
              saved: true,
              recordedLocalDayChanged: result.recordedLocalDayChanged,
            ),
          );
      }
    } on Object {
      await state.updateWithLock((current, emitter) async {
        await emitter.emit(current.copyWith(saving: false, saveError: true));
      });
    }
  }
}
