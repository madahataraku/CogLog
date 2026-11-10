import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/notification_settings_screen_view_model.dart';
import 'notification_settings_screen_providers.dart';

/// 通知設定の一覧。
///
/// Example:
/// ```dart
/// const NotificationSettingsScreenBody();
/// ```
@internal
class NotificationSettingsScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettingsScreenBody();
  /// ```
  const NotificationSettingsScreenBody({super.key});

  /// スイッチと許可案内を描画する。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettingsScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(NotificationSettingsScreenViewModel.provider);
    final entity = ref.watch(NotificationSettingsScreenProviders.entity);

    return FScaffold(
      header: FHeader.nested(
        title: Text(strings.screen_feature_notification_settings_title),
        prefixes: [
          FHeaderAction.back(
            onPress: viewModel.onBack,
            semanticsLabel:
                strings.screen_feature_notification_settings_back_semantics,
          ),
        ],
      ),
      child: ListView(
        children: [
          FTileGroup(
            children: [
              FTile(
                title: Text(
                  strings.screen_feature_notification_settings_enabled_item,
                ),
                suffix: FSwitch(
                  value: entity.enabled,
                  onChange: (value) {
                    viewModel.onToggleEnabled(value);
                  },
                ),
              ),
            ],
          ),
          if (entity.showPermissionGuidance)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                strings
                    .screen_feature_notification_settings_permission_guidance,
              ),
            ),
        ],
      ),
    );
  }
}
