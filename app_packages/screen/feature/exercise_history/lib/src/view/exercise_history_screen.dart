import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

import '../strings.dart';
import '../viewmodel/exercise_history_screen_view_model.dart';
import 'exercise_history_screen_body.dart';
import 'exercise_history_screen_providers.dart';

/// 月セレクタ付きの運動履歴カレンダー画面。
///
/// Example:
/// ```dart
/// const ExerciseHistoryScreen();
/// ```
class ExerciseHistoryScreen extends HookConsumerWidget {
  /// 運動履歴カレンダー画面を作る。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreen();
  /// ```
  const ExerciseHistoryScreen({super.key});

  /// タブ選択・前面復帰・詳細戻りで月を読み、Ready 後に段階8の文脈を出す。
  /// 見た目は [ExerciseHistoryScreenBody] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const ExerciseHistoryScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(ExerciseHistoryScreenViewModel.provider);
    final entity = ref.watch(ExerciseHistoryScreenProviders.entity);
    final session = ref.watch(tutorialRuntimeSessionProvider);
    final tabSelected = (ShellTabIndexScope.maybeOf(context) ?? -1) == 3;
    final lifecycle = useAppLifecycleState();
    final foreground =
        lifecycle == null || lifecycle == AppLifecycleState.resumed;
    final coldStarted = useRef(false);
    final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    final wasRouteCurrent = useRef(routeIsCurrent);

    useEffect(() {
      if (!tabSelected) {
        return null;
      }
      if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
        return null;
      }
      if (!coldStarted.value) {
        coldStarted.value = true;
        unawaited(viewModel.onColdStart());
      } else {
        unawaited(viewModel.onReloadSelectedMonth());
      }
      return null;
    }, [viewModel, tabSelected, lifecycle]);

    useEffect(() {
      if (routeIsCurrent &&
          !wasRouteCurrent.value &&
          coldStarted.value &&
          tabSelected) {
        unawaited(viewModel.onReloadSelectedMonth());
      }
      wasRouteCurrent.value = routeIsCurrent;
      return null;
    }, [routeIsCurrent, viewModel, tabSelected]);

    // Ready 後に段階8を評価する。
    useEffect(() {
      if (!tabSelected || !foreground || entity.showLoading) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) {
          return;
        }
        unawaited(viewModel.onEvaluateTutorial());
      });
      return null;
    }, [viewModel, tabSelected, lifecycle, entity.showLoading]);

    // 履歴タブを離れたとき、表示中の運動履歴文脈だけ閉じ提示済みを戻す。
    // （Evaluate が立てた activeKind を show 前に消さないよう、未選択時だけ動かす）
    useEffect(() {
      if (tabSelected) {
        return null;
      }
      if (session.activeKind != TutorialKind.history) {
        return null;
      }
      CoachMarkLauncher.dismissActive();
      session.clearActive();
      session.clearContextPresented(TutorialKind.history);
      return null;
    }, [tabSelected, session]);

    // 失敗・強制破棄では MarkSeen せず session の提示済みを戻す。
    useEffect(() {
      if (!entity.pendingTutorial) {
        return null;
      }
      if (!tabSelected || !foreground) {
        return null;
      }
      // 表示予約を消費して二重 show を防ぐ（推移文脈と同じ）。
      unawaited(viewModel.onAcknowledgeTutorial());
      void rollbackSession() {
        session.clearActive();
        session.clearContextPresented(TutorialKind.history);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) {
          return;
        }
        try {
          final reason = await CoachMarkLauncher.show(
            context,
            step: CoachMarkStep(
              targetId: CoachMarkTargetId.historyCalendar,
              title: strings.screen_feature_exercise_history_tutorial_title,
              body: strings.screen_feature_exercise_history_tutorial_body,
              primaryLabel: strings.view_coach_mark_close,
            ),
          );
          if (!context.mounted) {
            rollbackSession();
            return;
          }
          if (reason == CoachMarkDismissReason.forced) {
            rollbackSession();
            return;
          }
          await viewModel.onDismissTutorial();
        } on Object {
          rollbackSession();
        }
      });
      return null;
    }, [entity.pendingTutorial, viewModel, tabSelected, lifecycle, session]);

    return const ExerciseHistoryScreenBody();
  }
}
