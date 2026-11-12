import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/exercise_history_detail_screen_view_model.dart';

/// 運動履歴詳細の表示状態を Widget へ渡す。
///
/// Example:
/// ```dart
/// ref.watch(ExerciseHistoryDetailScreenProviders.state);
/// ```
final class ExerciseHistoryDetailScreenProviders {
  /// ViewModel の画面状態を監視する。
  static final state = StateStreamProvider.autoDispose.stateBy(
    ExerciseHistoryDetailScreenViewModel.provider,
    (ExerciseHistoryDetailScreenViewModel viewModel) => viewModel.screenState,
  );

  /// インスタンス化しない。static のみの束ねである。
  const ExerciseHistoryDetailScreenProviders._();
}
