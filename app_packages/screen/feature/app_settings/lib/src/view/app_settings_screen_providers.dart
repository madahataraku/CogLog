import 'package:meta/meta.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/app_settings_screen_view_model.dart';

/// アプリ設定画面の表示用 Provider。
@internal
final class AppSettingsScreenProviders {
  /// ViewModel の entity を監視する。
  ///
  /// Example:
  /// ```dart
  /// AppSettingsScreenProviders.entity;
  /// ```
  static final entity = StateStreamProvider.autoDispose.stateBy(
    AppSettingsScreenViewModel.provider,
    (AppSettingsScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。
  const AppSettingsScreenProviders._();
}
