import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';

import '../viewmodel/trends_screen_view_model.dart';
import 'trends_screen_body.dart';

/// 推移の期間・グループ・指標とグラフを示す画面。
///
/// Example:
/// ```dart
/// const TrendsScreen();
/// ```
class TrendsScreen extends HookConsumerWidget {
  /// 推移画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const TrendsScreen();
  /// ```
  const TrendsScreen({super.key});

  /// タブ選択と前面復帰で系列を読み、見た目は [TrendsScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const TrendsScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(TrendsScreenViewModel.provider);
    final trendsTabSelected = (ShellTabIndexScope.maybeOf(context) ?? -1) == 2;
    final lifecycle = useAppLifecycleState();
    useEffect(() {
      if (!trendsTabSelected) {
        return null;
      }
      if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
        return null;
      }
      unawaited(viewModel.onInitialize());
      return null;
    }, [viewModel, trendsTabSelected, lifecycle]);
    return const TrendsScreenBody();
  }
}
