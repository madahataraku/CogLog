import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

import '../viewmodel/goal_settings_screen_view_model.dart';
import 'goal_settings_screen_body.dart';

/// 一日あたり目標を入力・保存する画面。
///
/// Example:
/// ```dart
/// const GoalSettingsScreen();
/// ```
class GoalSettingsScreen extends HookConsumerWidget {
  /// 目標設定画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const GoalSettingsScreen();
  /// ```
  const GoalSettingsScreen({super.key});

  /// 初期化で目標を読み、段階3待ちのときはコーチマークを出す。
  /// 見た目は [GoalSettingsScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const GoalSettingsScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(GoalSettingsScreenViewModel.provider);
    final session = ref.watch(tutorialRuntimeSessionProvider);
    final advance = ref.watch(AdvanceTutorialMainUsecase.provider);
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);

    // メイン段階3: 目標タブ上でフォーム操作可能なコーチマーク。
    useEffect(() {
      final waiting =
          session.activeKind == TutorialKind.main &&
          session.mainStep == TutorialMainStep.goalRecommend;
      if (!waiting) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }
        final reason = await CoachMarkLauncher.show(
          context,
          step: CoachMarkStep(
            targetId: CoachMarkTargetId.goalDailyInputs,
            title: LocalizeStringDelegate.get(
              'screen_feature_top_tutorial_main_3_title',
            ),
            body: LocalizeStringDelegate.get(
              'screen_feature_top_tutorial_main_3_body',
            ),
            primaryLabel: LocalizeStringDelegate.get('view_coach_mark_next'),
            secondaryLabel: LocalizeStringDelegate.get('view_coach_mark_skip'),
            allowTargetInteraction: true,
            blockSystemBack: false,
          ),
        );
        if (!context.mounted) {
          return;
        }
        if (reason == CoachMarkDismissReason.secondary ||
            reason == CoachMarkDismissReason.systemBack) {
          await advance.execute(const AdvanceTutorialMainRequest.skip());
        }
      });
      return null;
    }, [session.activeKind, session.mainStep, advance]);

    return GoalSettingsScreenBody(
      onSaveSucceeded: () async {
        final result = await advance.execute(
          const AdvanceTutorialMainRequest.goalSaved(),
        );
        if (!context.mounted) {
          return;
        }
        if (result is AdvanceTutorialMainShowResult &&
            result.step == TutorialMainStep.meterRecommend) {
          unawaited(
            CoachMarkLauncher.show(
              context,
              step: CoachMarkStep(
                targetId: CoachMarkTargetId.navMeterCapture,
                title: LocalizeStringDelegate.get(
                  'screen_feature_top_tutorial_main_4_title',
                ),
                body: LocalizeStringDelegate.get(
                  'screen_feature_top_tutorial_main_4_body',
                ),
                primaryLabel: LocalizeStringDelegate.get(
                  'view_coach_mark_close',
                ),
              ),
            ).then((reason) async {
              if (reason == CoachMarkDismissReason.primary) {
                await advance.execute(const AdvanceTutorialMainRequest.next());
              }
            }),
          );
        }
      },
    );
  }
}
