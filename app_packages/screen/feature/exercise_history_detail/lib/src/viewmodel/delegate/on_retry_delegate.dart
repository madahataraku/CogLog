import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_exercise_history_detail/usecase_load_exercise_history_detail.dart';

import '../state/exercise_history_detail_screen_state.dart';
import 'on_initialize_delegate.dart';

/// 詳細の読込失敗を再試行する。
///
/// Example:
/// ```dart
/// OnRetryDelegate(
///   state: state,
///   loadDetailUsecase: loadDetailUsecase,
/// ).execute();
/// ```
final class OnRetryDelegate {
  /// [state] と詳細 Usecase を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnRetryDelegate(
  ///   state: state,
  ///   loadDetailUsecase: loadDetailUsecase,
  /// );
  /// ```
  const OnRetryDelegate({required this.state, required this.loadDetailUsecase});

  /// 更新する画面状態。
  final MutableStateStream<ExerciseHistoryDetailScreenState> state;

  /// 詳細の読み込み。
  final LoadExerciseHistoryDetailUsecase loadDetailUsecase;

  /// エラーがあるときだけ再読込する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    final prep = await state.updateWithLock((current, emitter) async {
      if (current.error == null || current.loading) {
        return null;
      }
      final id = current.id;
      await emitter.emit(
        current.copyWith(
          loading: true,
          missing: false,
          clearHistory: true,
          clearPhotoAbsolutePath: true,
          clearError: true,
        ),
      );
      return id;
    });
    if (prep == null) {
      return;
    }
    await loadExerciseHistoryDetail(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
      id: prep,
    );
  }
}
