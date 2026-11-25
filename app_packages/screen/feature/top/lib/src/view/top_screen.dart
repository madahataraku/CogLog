import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../strings.dart';
import '../viewmodel/top_screen_view_model.dart';
import 'map_gemma_meter_prepare_error.dart';
import 'should_evaluate_app_review_on_home.dart';
import 'top_conditional_advice_catalog.dart';
import 'top_screen_impl.dart';
import 'top_screen_providers.dart';

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

  /// ホームタブ選択・前面復帰で期間合計とアドバイス（定型はトーン付き）を読む。
  ///
  /// Ready 後はメインチュートリアルを優先し、完了後に (A)/(B) 誘導を出す。
  /// 見た目は [TopScreenImpl] に任せる。
  ///
  /// Example:
  /// ```dart
  /// const TopScreen();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(TopScreenViewModel.provider);
    final entity = ref.watch(TopScreenProviders.entity);
    final tutorialSession = ref.watch(tutorialRuntimeSessionProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final noExercise = AdviceTemplate(
      text: strings.screen_feature_top_advice_no_exercise,
      tone: AdviceTone.realized,
    );
    final fallbackTemplates = [
      AdviceTemplate(
        text: strings.screen_feature_top_advice_template_1,
        tone: AdviceTone.fun,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_template_2,
        tone: AdviceTone.happy,
      ),
      AdviceTemplate(
        text: strings.screen_feature_top_advice_template_3,
        tone: AdviceTone.fun,
      ),
    ];
    final conditionalCatalog = buildTopConditionalAdviceCatalog();
    final metricLabels = buildTopConditionalAdviceMetricLabels();
    final homeTabSelected = (ShellTabIndexScope.maybeOf(context) ?? 0) == 0;
    final lifecycle = useAppLifecycleState();
    final foreground =
        lifecycle == null || lifecycle == AppLifecycleState.resumed;

    useEffect(() {
      if (!homeTabSelected) {
        return null;
      }
      // 背面中は読まない。null は起動直後の未通知として前面扱いにする。
      if (!foreground) {
        return null;
      }
      viewModel.onInitialize(
        locale: locale,
        noExercise: noExercise,
        fallbackTemplates: fallbackTemplates,
        conditionalCatalog: conditionalCatalog,
        metricLabels: metricLabels,
      );
      return null;
    }, [viewModel, homeTabSelected, locale, lifecycle]);

    // Ready × 前面でメイン自動開始（モデル誘導より優先）。
    // loaded 判定は Delegate 内の state を見る。initialize 完了後に再評価する。
    useEffect(
      () {
        if (!homeTabSelected || !foreground) {
          return null;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          unawaited(() async {
            await viewModel.onEvaluateTutorialMain();
            await viewModel.onEvaluateTutorialAchievement();
          }());
        });
        return null;
      },
      [
        viewModel,
        homeTabSelected,
        lifecycle,
        entity.adviceText,
        entity.pendingModelDownloadGuidance,
        entity.pendingGemmaMeterGuidance,
      ],
    );

    // アプリ内レビュー（競合が無いときのみ。解消後も deps で再評価）。
    useEffect(
      () {
        final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
        if (!shouldEvaluateAppReviewOnHome(
          homeTabSelected: homeTabSelected,
          foreground: foreground,
          tutorialShowing: tutorialSession.isShowing,
          pendingTutorialMain: entity.pendingTutorialMain,
          pendingTutorialAchievement: entity.pendingTutorialAchievement,
          pendingModelDownloadGuidance: entity.pendingModelDownloadGuidance,
          pendingGemmaMeterGuidance: entity.pendingGemmaMeterGuidance,
          homeRouteIsCurrent: routeIsCurrent,
        )) {
          return null;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) {
            return;
          }
          final stillCurrent = ModalRoute.of(context)?.isCurrent ?? true;
          if (!shouldEvaluateAppReviewOnHome(
            homeTabSelected: (ShellTabIndexScope.maybeOf(context) ?? 0) == 0,
            foreground:
                (WidgetsBinding.instance.lifecycleState == null ||
                WidgetsBinding.instance.lifecycleState ==
                    AppLifecycleState.resumed),
            tutorialShowing: tutorialSession.isShowing,
            pendingTutorialMain: entity.pendingTutorialMain,
            pendingTutorialAchievement: entity.pendingTutorialAchievement,
            pendingModelDownloadGuidance: entity.pendingModelDownloadGuidance,
            pendingGemmaMeterGuidance: entity.pendingGemmaMeterGuidance,
            homeRouteIsCurrent: stillCurrent,
          )) {
            return;
          }
          unawaited(viewModel.onEvaluateAppReview());
        });
        return null;
      },
      [
        viewModel,
        homeTabSelected,
        lifecycle,
        tutorialSession.isShowing,
        entity.pendingTutorialMain,
        entity.pendingTutorialAchievement,
        entity.pendingModelDownloadGuidance,
        entity.pendingGemmaMeterGuidance,
        entity.adviceText,
      ],
    );

    useEffect(
      () {
        if (!entity.pendingTutorialMain) {
          return null;
        }
        if (!homeTabSelected || !foreground) {
          return null;
        }
        unawaited(viewModel.onAcknowledgeTutorialMain());
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) {
            return;
          }
          final step = entity.tutorialMainStep;
          if (step == null) {
            return;
          }
          // 段階3は目標タブ側で出す。
          if (step == TutorialMainStep.goalRecommend) {
            return;
          }
          final coachStep = _mainCoachMarkStep(step);
          final reason = await CoachMarkLauncher.show(context, step: coachStep);
          if (!context.mounted) {
            return;
          }
          if (reason == CoachMarkDismissReason.primary) {
            await viewModel.onAdvanceTutorialMain(
              const AdvanceTutorialMainRequest.next(),
            );
          } else if (reason == CoachMarkDismissReason.secondary ||
              reason == CoachMarkDismissReason.systemBack) {
            await viewModel.onAdvanceTutorialMain(
              const AdvanceTutorialMainRequest.skip(),
            );
          }
          if (!context.mounted) {
            return;
          }
          unawaited(viewModel.onEvaluateAppReview());
        });
        return null;
      },
      [
        entity.pendingTutorialMain,
        entity.tutorialMainStep,
        viewModel,
        homeTabSelected,
        lifecycle,
      ],
    );

    useEffect(
      () {
        if (!entity.pendingTutorialAchievement) {
          return null;
        }
        if (!homeTabSelected || !foreground) {
          return null;
        }
        if (tutorialSession.isShowing &&
            tutorialSession.activeKind == TutorialKind.main) {
          return null;
        }
        unawaited(viewModel.onAcknowledgeTutorialAchievement());
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) {
            return;
          }
          await CoachMarkLauncher.show(
            context,
            step: CoachMarkStep(
              targetId: CoachMarkTargetId.homeAchievementTrophy,
              title: strings.screen_feature_top_tutorial_achievement_title,
              body: strings.screen_feature_top_tutorial_achievement_body,
              primaryLabel: strings.view_coach_mark_close,
            ),
          );
          if (!context.mounted) {
            return;
          }
          await viewModel.onDismissTutorialAchievement();
          if (!context.mounted) {
            return;
          }
          unawaited(viewModel.onEvaluateAppReview());
        });
        return null;
      },
      [
        entity.pendingTutorialAchievement,
        viewModel,
        homeTabSelected,
        lifecycle,
      ],
    );

    useEffect(
      () {
        if (!entity.pendingModelDownloadGuidance) {
          return null;
        }
        // チュートリアル表示中はモデル誘導を出さない（提示済みにもしない）。
        if (tutorialSession.isShowing ||
            entity.pendingTutorialMain ||
            entity.pendingTutorialAchievement) {
          return null;
        }
        // 予約時点で同期的に提示済みにし、initialize 再入とのレースを防ぐ。
        unawaited(viewModel.onAcknowledgeModelDownloadGuidance());
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) {
            return;
          }
          await ModelDownloadGuidanceLauncher.show(
            context,
            onPrepare: viewModel.onPrepareModelDownloadGuidance,
          );
          if (!context.mounted) {
            return;
          }
          // (A) の show 完了後に (B) を評価する。
          await viewModel.onEvaluateGemmaMeterGuidance();
          if (!context.mounted) {
            return;
          }
          unawaited(viewModel.onEvaluateAppReview());
        });
        return null;
      },
      [
        entity.pendingModelDownloadGuidance,
        entity.pendingTutorialMain,
        entity.pendingTutorialAchievement,
        tutorialSession.isShowing,
        viewModel,
      ],
    );
    useEffect(
      () {
        if (!entity.pendingGemmaMeterGuidance) {
          return null;
        }
        if (tutorialSession.isShowing ||
            entity.pendingTutorialMain ||
            entity.pendingTutorialAchievement) {
          return null;
        }
        // ホーム選択かつ前面のときだけ出す。満たさない間は pending を残す。
        if (!homeTabSelected) {
          return null;
        }
        if (!foreground) {
          return null;
        }
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!context.mounted) {
            return;
          }
          final stillHome = (ShellTabIndexScope.maybeOf(context) ?? 0) == 0;
          final life = WidgetsBinding.instance.lifecycleState;
          final stillForeground =
              life == null || life == AppLifecycleState.resumed;
          if (!stillHome || !stillForeground) {
            return;
          }
          if (tutorialSession.isShowing) {
            return;
          }
          // 表示直前に提示済みにし、initialize 再入とのレースを防ぐ。
          await viewModel.onAcknowledgeGemmaMeterGuidance();
          if (!context.mounted) {
            return;
          }
          // (B) 専用文言・進捗・準備中は閉じる無効。
          await ModelDownloadGuidanceLauncher.show(
            context,
            title: strings.view_model_download_guidance_gemma_title,
            body: strings.view_model_download_guidance_gemma_body,
            disableDismissWhilePreparing: true,
            onPrepareProgress: viewModel.onPrepareGemmaMeterGuidance,
            mapPrepareError: mapGemmaMeterPrepareError,
          );
          if (!context.mounted) {
            return;
          }
          unawaited(viewModel.onEvaluateAppReview());
        });
        return null;
      },
      [
        entity.pendingGemmaMeterGuidance,
        entity.pendingTutorialMain,
        entity.pendingTutorialAchievement,
        tutorialSession.isShowing,
        viewModel,
        homeTabSelected,
        lifecycle,
      ],
    );
    return const TopScreenImpl();
  }
}

/// メイン段階に対応するコーチマーク step。
///
/// Example:
/// ```dart
/// _mainCoachMarkStep(TutorialMainStep.homeIntro);
/// ```
CoachMarkStep _mainCoachMarkStep(TutorialMainStep step) {
  return switch (step) {
    TutorialMainStep.homeIntro => CoachMarkStep(
      targetId: CoachMarkTargetId.homePeriodTotals,
      title: strings.screen_feature_top_tutorial_main_1_title,
      body: strings.screen_feature_top_tutorial_main_1_body,
      primaryLabel: strings.view_coach_mark_next,
    ),
    TutorialMainStep.tabOverview => CoachMarkStep(
      targetId: CoachMarkTargetId.navHome,
      title: strings.screen_feature_top_tutorial_main_2_title,
      body: strings.screen_feature_top_tutorial_main_2_body,
      primaryLabel: strings.view_coach_mark_next,
    ),
    TutorialMainStep.goalRecommend => CoachMarkStep(
      targetId: CoachMarkTargetId.goalDailyInputs,
      title: strings.screen_feature_top_tutorial_main_3_title,
      body: strings.screen_feature_top_tutorial_main_3_body,
      primaryLabel: strings.view_coach_mark_next,
      secondaryLabel: strings.view_coach_mark_skip,
      allowTargetInteraction: true,
      blockSystemBack: false,
    ),
    TutorialMainStep.meterRecommend => CoachMarkStep(
      targetId: CoachMarkTargetId.navMeterCapture,
      title: strings.screen_feature_top_tutorial_main_4_title,
      body: strings.screen_feature_top_tutorial_main_4_body,
      primaryLabel: strings.view_coach_mark_close,
    ),
  };
}
