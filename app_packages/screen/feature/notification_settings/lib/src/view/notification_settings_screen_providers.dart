import 'package:meta/meta.dart';
import 'package:state_stream_riverpod/state_stream_riverpod.dart';

import '../viewmodel/notification_settings_screen_view_model.dart';

/// 通知設定画面の表示用 Provider。
@internal
final class NotificationSettingsScreenProviders {
  /// ViewModel の entity を監視する。
  ///
  /// Example:
  /// ```dart
  /// NotificationSettingsScreenProviders.entity;
  /// ```
  static final entity = StateStreamProvider.autoDispose.stateBy(
    NotificationSettingsScreenViewModel.provider,
    (NotificationSettingsScreenViewModel viewModel) => viewModel.entity,
  );

  /// インスタンス化しない。
  const NotificationSettingsScreenProviders._();
}
