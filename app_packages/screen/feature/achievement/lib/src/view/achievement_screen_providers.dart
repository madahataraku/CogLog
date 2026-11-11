import 'package:meta/meta.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/achievement_screen_view_model.dart';

/// アチーブメント画面の表示用 Provider。
@internal
final class AchievementScreenProviders {
  /// ViewModel の entity を監視する。
  ///
  /// Example:
  /// ```dart
  /// AchievementScreenProviders.entity;
  /// ```
  static final entity = StateStreamProvider.autoDispose.stateBy(
    AchievementScreenViewModel.provider,
    (AchievementScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。
  const AchievementScreenProviders._();
}
