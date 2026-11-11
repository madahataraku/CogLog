import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';

import '../viewmodel/exercise_history_screen_view_model.dart';
import 'exercise_history_screen_body.dart';

/// 月セレクタ付きの運動履歴カレンダー画面。
///
/// Example:
/// ```dart
/// const ExerciseHistoryScreen();
/// ```
class ExerciseHistoryScreen extends HookConsumerWidget {
  /// 運動履歴カレンダー画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreen();
  /// ```
  const ExerciseHistoryScreen({super.key});

  /// タブ選択・前面復帰・詳細戻りで月を読み、見た目は [ExerciseHistoryScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(ExerciseHistoryScreenViewModel.provider);
    final tabSelected = (ShellTabIndexScope.maybeOf(context) ?? -1) == 3;
    final lifecycle = useAppLifecycleState();
    final coldStarted = useRef(false);
    final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final wasRouteCurrent = useRef(routeIsCurrent);

    useEffect(() {
      if (!tabSelected) {
        return null;
      }
      if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
        return null;
      }
      if (!coldStarted.value) {
        coldStarted.value = true;
        unawaited(viewModel.onColdStart());
      } else {
        unawaited(viewModel.onReloadSelectedMonth());
      }
      return null;
    }, [viewModel, tabSelected, lifecycle]);

    useEffect(() {
      if (routeIsCurrent &&
          !wasRouteCurrent.value &&
          coldStarted.value &&
          tabSelected) {
        unawaited(viewModel.onReloadSelectedMonth());
      }
      wasRouteCurrent.value = routeIsCurrent;
      return null;
    }, [routeIsCurrent, viewModel, tabSelected]);

    return const ExerciseHistoryScreenBody();
  }
}
