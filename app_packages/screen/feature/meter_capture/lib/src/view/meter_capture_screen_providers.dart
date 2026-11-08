import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/meter_capture_screen_view_model.dart';

/// メーター記録画面の表示状態を Widget へ渡す。
///
/// Example:
/// ```dart
/// ref.watch(MeterCaptureScreenProviders.entity);
/// ```
final class MeterCaptureScreenProviders {
  /// ViewModel の entity を監視する。
  static final entity = StateStreamProvider.autoDispose.stateBy(
    MeterCaptureScreenViewModel.provider,
    (MeterCaptureScreenViewModel viewModel) => viewModel.entity,
  );

  /// ViewModel の画面状態を監視する。
  static final state = StateStreamProvider.autoDispose.stateBy(
    MeterCaptureScreenViewModel.provider,
    (MeterCaptureScreenViewModel viewModel) => viewModel.screenState,
  );

  /// インスタンス化しない。static のみの束ねである。
  const MeterCaptureScreenProviders._();
}
