import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/debug_screen_view_model.dart';
import 'debug_screen_body.dart';

/// 端末上 LLM の診断とアプリログ。
///
/// Example:
/// ```dart
/// const DebugScreen();
/// ```
class DebugScreen extends HookConsumerWidget {
  /// デバッグ画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreen();
  /// ```
  const DebugScreen({super.key});

  /// 初回診断を走らせ、見た目は [DebugScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const DebugScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(DebugScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const DebugScreenBody();
  }
}
