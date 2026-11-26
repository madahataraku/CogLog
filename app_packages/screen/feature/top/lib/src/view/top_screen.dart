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
import 'map_meter_vl_prepare_error.dart';
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
          unawaited(viewModel.onEvaluateTutorialMain());
        });
        return null;
      },
      [
        viewModel,
        homeTabSelected,
        lifecycle,
        entity.adviceText,
        entity.pendingModelDownloadGuidance,
        entity.pendingMeterVlGuidance,
      ],
    );

    // pending 立ち上がりだけを契機に表示を始める。段階1→2→3は同一コールバック内で
    // 連鎖し、tutorialMainStep 変更による effect 再入と二重 show を避ける。
    useEffect(() {
      if (!entity.pendingTutorialMain) {
        return null;
      }
      if (!homeTabSelected || !foreground) {
        return null;
      }
      final initialStep = entity.tutorialMainStep;
      unawaited(viewModel.onAcknowledgeTutorialMain());
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted || initialStep == null) {
          return;
        }
        bool canShowOnHome() {
          final stillHome = (ShellTabIndexScope.maybeOf(context) ?? 0) == 0;
          final life = WidgetsBinding.instance.lifecycleState;
          final stillForeground =
              life == null || life == AppLifecycleState.resumed;
          return stillHome && stillForeground;
        }

        var step = initialStep;
        while (true) {
          if (!context.mounted) {
            return;
          }
          if (!canShowOnHome()) {
            // ホーム以外／背面なら連鎖を止め、復帰時に同じ段階から再開する。
            await viewModel.onParkTutorialMain(step);
            return;
          }
          final reason = await CoachMarkLauncher.show(
            context,
            step: _mainCoachMarkStep(step),
          );
          if (!context.mounted) {
            return;
          }
          if (reason == CoachMarkDismissReason.forced) {
            return;
          }
          if (reason == CoachMarkDismissReason.secondary ||
              reason == CoachMarkDismissReason.systemBack) {
            await viewModel.onAdvanceTutorialMain(
              const AdvanceTutorialMainRequest.skip(),
            );
            return;
          }
          final result = await viewModel.onAdvanceTutorialMain(
            const AdvanceTutorialMainRequest.next(),
          );
          switch (result) {
            case final AdvanceTutorialMainShowResult show:
              if (show.navigateToGoalTab) {
                // 段階3オーバーレイ／disableBackButton ルートの破棄を待ってから遷移する。
                await Future<void>.delayed(const Duration(milliseconds: 300));
                if (!context.mounted) {
                  return;
                }
                viewModel.goToGoalSettingsTab();
                return;
              }
              step = show.step;
            case AdvanceTutorialMainCompletedResult():
            case AdvanceTutorialMainNoopResult():
              return;
          }
        }
      });
      return null;
    }, [entity.pendingTutorialMain, viewModel, homeTabSelected, lifecycle]);

    useEffect(
      () {
        if (!entity.pendingModelDownloadGuidance) {
          return null;
        }
        // チュートリアル表示中はモデル誘導を出さない（提示済みにもしない）。
        if (tutorialSession.isShowing || entity.pendingTutorialMain) {
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
          await viewModel.onEvaluateMeterVlGuidance();
        });
        return null;
      },
      [
        entity.pendingModelDownloadGuidance,
        entity.pendingTutorialMain,
        tutorialSession.isShowing,
        viewModel,
      ],
    );
    useEffect(
      () {
        if (!entity.pendingMeterVlGuidance) {
          return null;
        }
        if (tutorialSession.isShowing || entity.pendingTutorialMain) {
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
          await viewModel.onAcknowledgeMeterVlGuidance();
          if (!context.mounted) {
            return;
          }
          // (B) 専用文言・進捗・準備中は閉じる無効。
          await ModelDownloadGuidanceLauncher.show(
            context,
            title: strings.view_model_download_guidance_meter_vl_title,
            body: strings.view_model_download_guidance_meter_vl_body,
            disableDismissWhilePreparing: true,
            onPrepareProgress: viewModel.onPrepareMeterVlGuidance,
            mapPrepareError: mapMeterVlPrepareError,
          );
        });
        return null;
      },
      [
        entity.pendingMeterVlGuidance,
        entity.pendingTutorialMain,
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
    TutorialMainStep.goalProgressIntro => CoachMarkStep(
      targetId: CoachMarkTargetId.homeGoalRings,
      title: strings.screen_feature_top_tutorial_main_2_title,
      body: strings.screen_feature_top_tutorial_main_2_body,
      primaryLabel: strings.view_coach_mark_next,
    ),
    TutorialMainStep.goalRecommend => CoachMarkStep(
      targetId: CoachMarkTargetId.navGoalSettings,
      title: strings.screen_feature_top_tutorial_main_3_title,
      body: strings.screen_feature_top_tutorial_main_3_body,
      primaryLabel: strings.view_coach_mark_next,
      secondaryLabel: strings.view_coach_mark_skip,
    ),
    TutorialMainStep.meterRecommend => CoachMarkStep(
      targetId: CoachMarkTargetId.navMeterCapture,
      title: strings.screen_feature_top_tutorial_main_4_title,
      body: strings.screen_feature_top_tutorial_main_4_body,
      primaryLabel: strings.view_coach_mark_close,
    ),
    TutorialMainStep.trendsRecommend => CoachMarkStep(
      targetId: CoachMarkTargetId.navTrends,
      title: strings.screen_feature_top_tutorial_main_5_title,
      body: strings.screen_feature_top_tutorial_main_5_body,
      primaryLabel: strings.view_coach_mark_close,
    ),
    TutorialMainStep.historyRecommend => CoachMarkStep(
      targetId: CoachMarkTargetId.navExerciseHistory,
      title: strings.screen_feature_top_tutorial_main_6_title,
      body: strings.screen_feature_top_tutorial_main_6_body,
      primaryLabel: strings.view_coach_mark_close,
    ),
    TutorialMainStep.achievementRecommend => CoachMarkStep(
      targetId: CoachMarkTargetId.homeAchievementTrophy,
      title: strings.screen_feature_top_tutorial_main_7_title,
      body: strings.screen_feature_top_tutorial_main_7_body,
      primaryLabel: strings.view_coach_mark_close,
    ),
  };
}
