import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/trends_screen_view_model.dart';

/// 推移画面の表示状態を Widget へ渡す。
///
/// Example:
/// ```dart
/// ref.watch(TrendsScreenProviders.entity);
/// ```
final class TrendsScreenProviders {
  /// ViewModel の entity を監視する。
  static final entity = StateStreamProvider.autoDispose.stateBy(
    TrendsScreenViewModel.provider,
    (TrendsScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。static のみの束ねである。
  const TrendsScreenProviders._();
}
