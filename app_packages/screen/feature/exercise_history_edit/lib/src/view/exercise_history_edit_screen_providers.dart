import 'package:meta/meta.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/exercise_history_edit_screen_view_model.dart';

/// 運動履歴編集の表示状態を Widget へ渡す。
///
/// Example:
/// ```dart
/// ref.watch(ExerciseHistoryEditScreenProviders.entity);
/// ```
@internal
final class ExerciseHistoryEditScreenProviders {
  /// ViewModel の entity を監視する。
  static final entity = StateStreamProvider.autoDispose.stateBy(
    ExerciseHistoryEditScreenViewModel.provider,
    (ExerciseHistoryEditScreenViewModel viewModel) => viewModel.entity,
  );

  /// ViewModel の画面状態を監視する。
  static final state = StateStreamProvider.autoDispose.stateBy(
    ExerciseHistoryEditScreenViewModel.provider,
    (ExerciseHistoryEditScreenViewModel viewModel) => viewModel.screenState,
  );

  /// インスタンス化しない。static のみの束ねである。
  const ExerciseHistoryEditScreenProviders._();
}
