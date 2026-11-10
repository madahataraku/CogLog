import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/notification_settings_screen_view_model.dart';
import 'notification_settings_screen_body.dart';

/// 通知の ON/OFF 設定。
///
/// Example:
/// ```dart
/// const NotificationSettingsScreen();
/// ```
class NotificationSettingsScreen extends HookConsumerWidget {
  /// 通知設定画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettingsScreen();
  /// ```
  const NotificationSettingsScreen({super.key});

  /// 初回読み込みのあと本文を出す。
  ///
  /// Example:
  /// ```dart
  /// const NotificationSettingsScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(NotificationSettingsScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const NotificationSettingsScreenBody();
  }
}
