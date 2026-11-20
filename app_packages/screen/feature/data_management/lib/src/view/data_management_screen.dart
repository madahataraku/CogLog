import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/data_management_screen_view_model.dart';
import 'data_management_screen_body.dart';

/// データエクスポート／インポートの設定子画面。
///
/// Example:
/// ```dart
/// const DataManagementScreen();
/// ```
class DataManagementScreen extends HookConsumerWidget {
  /// データ管理画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const DataManagementScreen();
  /// ```
  const DataManagementScreen({super.key});

  /// ViewModel を用意し本文を出す。
  ///
  /// Example:
  /// ```dart
  /// const DataManagementScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(DataManagementScreenViewModel.provider);
    return const DataManagementScreenBody();
  }
}
