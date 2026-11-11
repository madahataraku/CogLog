import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/achievement_screen_view_model.dart';
import 'achievement_screen_body.dart';

/// アチーブメント一覧画面。
///
/// Example:
/// ```dart
/// const AchievementScreen();
/// ```
class AchievementScreen extends HookConsumerWidget {
  /// アチーブメント画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreen();
  /// ```
  const AchievementScreen({super.key});

  /// 初回読込を走らせ、見た目は [AchievementScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(AchievementScreenViewModel.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);
    return const AchievementScreenBody();
  }
}
