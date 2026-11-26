import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

import '../strings.dart';
import '../viewmodel/goal_settings_screen_view_model.dart';
import 'goal_settings_screen_body.dart';
import 'goal_settings_screen_providers.dart';

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

  /// 初期化で目標を読み、条件を満たせば目標設定文脈（3手）を出す。
  /// 見た目は [GoalSettingsScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const GoalSettingsScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(GoalSettingsScreenViewModel.provider);
    final entity = ref.watch(GoalSettingsScreenProviders.entity);
    final evaluate = ref.watch(EvaluateTutorialContextUsecase.provider);
    final markSeen = ref.watch(MarkTutorialContextSeenUsecase.provider);
    final session = ref.watch(tutorialRuntimeSessionProvider);
    final tabSelected = (ShellTabIndexScope.maybeOf(context) ?? -1) == 4;
    useEffect(() {
      viewModel.onInitialize();
      return null;
    }, [viewModel]);

    // IndexedStack 保持のため、目標タブ選択かつ読込後に再評価する。
    useEffect(() {
      if (!tabSelected || !entity.loaded) {
        return null;
      }
      bool isGoalTabSelected() =>
          (ShellTabIndexScope.maybeOf(context) ?? -1) == 4;
      void rollbackSession() {
        session.clearActive();
        session.clearContextPresented(TutorialKind.goalSettings);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted || !isGoalTabSelected()) {
          return;
        }
        final decision = await evaluate.execute(
          const EvaluateTutorialContextRequest(kind: TutorialKind.goalSettings),
        );
        if (!decision.shouldShow) {
          return;
        }
        // 出すときだけレイアウトを待ち、出さない経路では Timer／余剰フレームを残さない。
        await WidgetsBinding.instance.endOfFrame;
        if (!context.mounted || !isGoalTabSelected()) {
          rollbackSession();
          return;
        }
        final steps = <CoachMarkStep>[
          CoachMarkStep(
            targetId: CoachMarkTargetId.goalDailyInputs,
            title: strings.screen_feature_goal_settings_tutorial_1_title,
            body: strings.screen_feature_goal_settings_tutorial_1_body,
            primaryLabel: LocalizeStringDelegate.get('view_coach_mark_next'),
          ),
          CoachMarkStep(
            targetId: CoachMarkTargetId.goalWeeklyDays,
            title: strings.screen_feature_goal_settings_tutorial_2_title,
            body: strings.screen_feature_goal_settings_tutorial_2_body,
            primaryLabel: LocalizeStringDelegate.get('view_coach_mark_next'),
          ),
          CoachMarkStep(
            targetId: CoachMarkTargetId.goalAutoUpdate,
            title: strings.screen_feature_goal_settings_tutorial_3_title,
            body: strings.screen_feature_goal_settings_tutorial_3_body,
            primaryLabel: LocalizeStringDelegate.get('view_coach_mark_close'),
          ),
        ];
        for (final step in steps) {
          if (!context.mounted || !isGoalTabSelected()) {
            rollbackSession();
            return;
          }
          final reason = await CoachMarkLauncher.show(context, step: step);
          if (reason == CoachMarkDismissReason.forced) {
            rollbackSession();
            return;
          }
        }
        if (!context.mounted || !isGoalTabSelected()) {
          rollbackSession();
          return;
        }
        await markSeen.execute(
          const MarkTutorialContextSeenRequest(kind: TutorialKind.goalSettings),
        );
      });
      return null;
    }, [tabSelected, entity.loaded, evaluate, markSeen, session]);

    return const GoalSettingsScreenBody();
  }
}
