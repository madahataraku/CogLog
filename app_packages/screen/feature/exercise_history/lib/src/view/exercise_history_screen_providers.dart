import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/exercise_history_screen_view_model.dart';

/// 運動履歴一覧の表示状態を Widget へ渡す。
///
/// Example:
/// ```dart
/// ref.watch(ExerciseHistoryScreenProviders.entity);
/// ```
final class ExerciseHistoryScreenProviders {
  /// ViewModel の entity を監視する。
  static final entity = StateStreamProvider.autoDispose.stateBy(
    ExerciseHistoryScreenViewModel.provider,
    (ExerciseHistoryScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。static のみの束ねである。
  const ExerciseHistoryScreenProviders._();
}
