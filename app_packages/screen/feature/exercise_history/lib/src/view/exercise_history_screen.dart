import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/exercise_history_screen_view_model.dart';
import 'exercise_history_screen_body.dart';

/// 月セレクタ付きの運動履歴一覧画面。
///
/// Example:
/// ```dart
/// const ExerciseHistoryScreen();
/// ```
class ExerciseHistoryScreen extends HookConsumerWidget {
  /// 運動履歴一覧画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreen();
  /// ```
  const ExerciseHistoryScreen({super.key});

  /// 初期化で当月を読み、見た目は [ExerciseHistoryScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(ExerciseHistoryScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const ExerciseHistoryScreenBody();
  }
}
