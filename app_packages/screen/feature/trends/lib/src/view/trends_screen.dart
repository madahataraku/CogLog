import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

import '../strings.dart';
import '../viewmodel/trends_screen_view_model.dart';
import 'trends_screen_body.dart';
import 'trends_screen_providers.dart';

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

  /// タブ選択と前面復帰で系列を読み、Ready 後に段階7の文脈を出す。
  /// 見た目は [TrendsScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const TrendsScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(TrendsScreenViewModel.provider);
    final entity = ref.watch(TrendsScreenProviders.entity);
    final trendsTabSelected = (ShellTabIndexScope.maybeOf(context) ?? -1) == 2;
    final lifecycle = useAppLifecycleState();
    final foreground =
        lifecycle == null || lifecycle == AppLifecycleState.resumed;

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

    // Ready 後に段階7を評価する。
    useEffect(() {
      if (!trendsTabSelected || !foreground || entity.loading) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        unawaited(viewModel.onEvaluateTutorial());
      });
      return null;
    }, [viewModel, trendsTabSelected, lifecycle, entity.loading]);

    useEffect(() {
      if (!entity.pendingTutorial) {
        return null;
      }
      if (!trendsTabSelected || !foreground) {
        return null;
      }
      unawaited(viewModel.onAcknowledgeTutorial());
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }
        await CoachMarkLauncher.show(
          context,
          step: CoachMarkStep(
            targetId: CoachMarkTargetId.trendsChart,
            title: strings.screen_feature_trends_tutorial_title,
            body: strings.screen_feature_trends_tutorial_body,
            primaryLabel: strings.view_coach_mark_close,
          ),
        );
        if (!context.mounted) {
          return;
        }
        await viewModel.onDismissTutorial();
      });
      return null;
    }, [entity.pendingTutorial, viewModel, trendsTabSelected, lifecycle]);

    return const TrendsScreenBody();
  }
}
