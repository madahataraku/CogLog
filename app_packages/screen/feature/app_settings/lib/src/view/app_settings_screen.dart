import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/app_settings_screen_view_model.dart';
import 'app_settings_screen_body.dart';

/// アプリ全体の設定画面。
///
/// Example:
/// ```dart
/// const AppSettingsScreen();
/// ```
class AppSettingsScreen extends HookConsumerWidget {
  /// アプリ設定画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsScreen();
  /// ```
  const AppSettingsScreen({super.key});

  /// 初回読込を走らせ、見た目は [AppSettingsScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(AppSettingsScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const AppSettingsScreenBody();
  }
}
