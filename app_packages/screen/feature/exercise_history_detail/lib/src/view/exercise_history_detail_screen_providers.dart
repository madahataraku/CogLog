import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/exercise_history_detail_screen_view_model.dart';

/// 運動履歴詳細の表示状態を Widget へ渡す。
///
/// Example:
/// ```dart
/// ref.watch(ExerciseHistoryDetailScreenProviders.entity);
/// ```
final class ExerciseHistoryDetailScreenProviders {
  /// ViewModel の entity を監視する。
  static final entity = StateStreamProvider.autoDispose.stateBy(
    ExerciseHistoryDetailScreenViewModel.provider,
    (ExerciseHistoryDetailScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。static のみの束ねである。
  const ExerciseHistoryDetailScreenProviders._();
}
