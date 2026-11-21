import 'package:meta/meta.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/data_management_screen_view_model.dart';

/// データ管理画面の表示用 Provider。
@internal
final class DataManagementScreenProviders {
  /// ViewModel の entity を監視する。
  ///
  /// Example:
  /// ```dart
  /// DataManagementScreenProviders.entity;
  /// ```
  static final entity = StateStreamProvider.autoDispose.stateBy(
    DataManagementScreenViewModel.provider,
    (DataManagementScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。
  const DataManagementScreenProviders._();
}
