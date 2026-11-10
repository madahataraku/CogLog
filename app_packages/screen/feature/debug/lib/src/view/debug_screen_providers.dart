import 'package:meta/meta.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/debug_screen_view_model.dart';

/// デバッグ画面の表示用 Provider。
@internal
final class DebugScreenProviders {
  /// ViewModel の entity を監視する。
  ///
  /// Example:
  /// ```dart
  /// DebugScreenProviders.entity;
  /// ```
  static final entity = StateStreamProvider.autoDispose.stateBy(
    DebugScreenViewModel.provider,
    (DebugScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。
  const DebugScreenProviders._();
}
