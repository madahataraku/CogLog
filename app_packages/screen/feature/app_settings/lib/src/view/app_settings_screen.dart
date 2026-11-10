import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app_settings_screen_body.dart';

/// アプリ全体の設定画面。
///
/// Example:
/// ```dart
/// const AppSettingsScreen();
/// ```
class AppSettingsScreen extends ConsumerWidget {
  /// アプリ設定画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsScreen();
  /// ```
  const AppSettingsScreen({super.key});

  /// 見た目は [AppSettingsScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const AppSettingsScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      const AppSettingsScreenBody();
}
