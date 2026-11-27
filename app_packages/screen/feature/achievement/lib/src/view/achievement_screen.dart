import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

import '../strings.dart';
import '../viewmodel/achievement_screen_view_model.dart';
import '../viewmodel/entity/achievement_screen_entity.dart';
import '../viewmodel/rollback_achievement_tutorial_session.dart';
import 'achievement_screen_body.dart';
import 'achievement_screen_providers.dart';

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

  /// 初回読込・文脈コーチマークを走らせ、見た目は [AchievementScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const AchievementScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(AchievementScreenViewModel.provider);
    final entity = ref.watch(AchievementScreenProviders.entity);
    final session = ref.watch(tutorialRuntimeSessionProvider);
    final lifecycle = useAppLifecycleState();
    final foreground =
        lifecycle == null || lifecycle == AppLifecycleState.resumed;
    final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final failureRetried = useRef(false);

    useEffect(() {
      unawaited(viewModel.onInitialize());
      return null;
    }, [viewModel]);

    final isReady = entity is AchievementScreenReadyEntity;
    final pendingTutorial =
        entity is AchievementScreenReadyEntity && entity.pendingTutorial;

    // Ready 後に文脈を評価する。離脱後に完了した Evaluate は破棄する。
    useEffect(() {
      if (!isReady || !foreground || !routeIsCurrent) {
        return null;
      }
      var cancelled = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (cancelled || !context.mounted) {
          return;
        }
        await viewModel.onEvaluateTutorial();
        if (cancelled || !context.mounted) {
          rollbackAchievementTutorialSession(session);
          if (context.mounted) {
            await viewModel.onAcknowledgeTutorial();
          }
        }
      });
      return () {
        cancelled = true;
      };
    }, [viewModel, isReady, lifecycle, routeIsCurrent, session]);

    // 画面を離れたとき、表示中のアチーブメント文脈だけ閉じ提示済みを戻す。
    useEffect(() {
      if (routeIsCurrent) {
        return null;
      }
      if (session.activeKind != TutorialKind.achievement) {
        return null;
      }
      CoachMarkLauncher.dismissActive();
      rollbackAchievementTutorialSession(session);
      return null;
    }, [routeIsCurrent, session]);

    // 失敗・強制破棄では MarkSeen せず、所有中の session だけ戻す。
    useEffect(() {
      if (!pendingTutorial) {
        return null;
      }
      if (!foreground || !routeIsCurrent) {
        return null;
      }
      unawaited(viewModel.onAcknowledgeTutorial());

      Future<void> retryEvaluateOnceIfNeeded() async {
        if (failureRetried.value) {
          return;
        }
        if (!context.mounted || !(ModalRoute.of(context)?.isCurrent ?? false)) {
          return;
        }
        failureRetried.value = true;
        await viewModel.onEvaluateTutorial();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }
        try {
          final reason = await CoachMarkLauncher.show(
            context,
            step: CoachMarkStep(
              targetId: CoachMarkTargetId.achievementList,
              title: strings.screen_feature_achievement_tutorial_title,
              body: strings.screen_feature_achievement_tutorial_body,
              primaryLabel: strings.view_coach_mark_close,
            ),
          );
          if (!context.mounted) {
            rollbackAchievementTutorialSession(session);
            return;
          }
          if (reason == CoachMarkDismissReason.forced) {
            rollbackAchievementTutorialSession(session);
            await retryEvaluateOnceIfNeeded();
            return;
          }
          await viewModel.onDismissTutorial();
        } on Object {
          rollbackAchievementTutorialSession(session);
          await retryEvaluateOnceIfNeeded();
        }
      });
      return null;
    }, [pendingTutorial, viewModel, lifecycle, routeIsCurrent, session]);

    return const AchievementScreenBody();
  }
}
