import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/exercise_history_detail_screen_view_model.dart';
import 'exercise_history_detail_screen_body.dart';

/// 運動履歴 1 件の詳細画面。
///
/// Example:
/// ```dart
/// ExerciseHistoryDetailScreen(id: 'id');
/// ```
class ExerciseHistoryDetailScreen extends HookConsumerWidget {
  /// [id] を持つ詳細画面を作る。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryDetailScreen(id: 'id');
  /// ```
  const ExerciseHistoryDetailScreen({required this.id, super.key});

  /// 対象の運動履歴 ID。
  final String id;

  /// 初期化で詳細を読み、見た目は [ExerciseHistoryDetailScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// ExerciseHistoryDetailScreen(id: 'id');
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(ExerciseHistoryDetailScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize(id: id);
      return null;
    }, [viewModel, id]);
    return const ExerciseHistoryDetailScreenBody();
  }
}
