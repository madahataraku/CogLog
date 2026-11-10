import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../viewmodel/trends_screen_view_model.dart';
import 'trends_screen_body.dart';

/// 推移の期間・グループを選ぶ画面（Phase1 はグラフ本体なし）。
///
/// Example:
/// ```dart
/// const TrendsScreen();
/// ```
class TrendsScreen extends ConsumerWidget {
  /// 推移画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const TrendsScreen();
  /// ```
  const TrendsScreen({super.key});

  /// ViewModel を保持し、見た目は [TrendsScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const TrendsScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(TrendsScreenViewModel.provider);
    return const TrendsScreenBody();
  }
}
