import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';

import '../strings.dart';
import '../viewmodel/top_screen_view_model.dart';
import 'top_screen_impl.dart';

/// ホーム。本日、今週、今月の合計を示す。
///
/// Example:
/// ```dart
/// const TopScreen();
/// ```
class TopScreen extends HookConsumerWidget {
  /// トップ画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const TopScreen();
  /// ```
  const TopScreen({super.key});

  /// ホームタブ選択・前面復帰で期間合計とアドバイスを読み、見た目は [TopScreenImpl] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const TopScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(TopScreenViewModel.provider);
    final locale = Localizations.localeOf(context).languageCode;
    final noExerciseTemplate = strings.screen_feature_top_advice_no_exercise;
    final fallbackTemplates = [
      strings.screen_feature_top_advice_template_1,
      strings.screen_feature_top_advice_template_2,
      strings.screen_feature_top_advice_template_3,
    ];
    final homeTabSelected = (ShellTabIndexScope.maybeOf(context) ?? 0) == 0;
    final lifecycle = useAppLifecycleState();
    useEffect(() {
      if (!homeTabSelected) {
        return null;
      }
      // 背面中は読まない。null は起動直後の未通知として前面扱いにする。
      if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
        return null;
      }
      viewModel.onInitialize(
        locale: locale,
        noExerciseTemplate: noExerciseTemplate,
        fallbackTemplates: fallbackTemplates,
      );
      return null;
    }, [viewModel, homeTabSelected, locale, lifecycle]);
    return const TopScreenImpl();
  }
}
