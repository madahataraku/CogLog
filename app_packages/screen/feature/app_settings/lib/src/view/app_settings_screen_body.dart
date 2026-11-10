import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/app_settings_screen_view_model.dart';

/// アプリ設定の一覧。
///
/// Example:
/// ```dart
/// const AppSettingsScreenBody();
/// ```
@internal
class AppSettingsScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsScreenBody();
  /// ```
  const AppSettingsScreenBody({super.key});

  /// 戻るとデバッグ項目を描画する。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(AppSettingsScreenViewModel.provider);
    return FScaffold(
      header: FHeader.nested(
        title: Text(strings.screen_feature_app_settings_title),
        prefixes: [
          FHeaderAction.back(
            onPress: viewModel.onBack,
            semanticsLabel: strings.screen_feature_app_settings_back_semantics,
          ),
        ],
      ),
      child: ListView(
        children: [
          FTileGroup(
            children: [
              FTile(
                title: Text(strings.screen_feature_app_settings_debug_item),
                onPress: viewModel.onOpenDebug,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
