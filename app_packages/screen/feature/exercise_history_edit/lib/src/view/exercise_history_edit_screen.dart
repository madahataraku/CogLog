import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/exercise_history_edit_screen_view_model.dart';
import 'exercise_history_edit_screen_body.dart';

/// 運動履歴 1 件の編集画面。
///
/// Example:
/// ```dart
/// ExerciseHistoryEditScreen(id: 'id');
/// ```
class ExerciseHistoryEditScreen extends HookConsumerWidget {
  /// [id] を持つ編集画面を作る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryEditScreen(id: 'id');
  /// ```
  const ExerciseHistoryEditScreen({required this.id, super.key});

  /// 対象の運動履歴 ID。
  final String id;

  /// 初期化で詳細を読み、見た目は [ExerciseHistoryEditScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryEditScreen(id: 'id');
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(ExerciseHistoryEditScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize(id: id);
      return null;
    }, [viewModel, id]);
    return const ExerciseHistoryEditScreenBody();
  }
}
