import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../strings.dart';
import '../viewmodel/top_screen_view_model.dart';
import 'map_gemma_meter_prepare_error.dart';
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
  /// Ready 後は (A) 誘導、その完了後または (A) 無しのとき (B) 誘導を出す。
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
        noExercise: noExercise,
        fallbackTemplates: fallbackTemplates,
        conditionalCatalog: conditionalCatalog,
        metricLabels: metricLabels,
      );
      return null;
    }, [viewModel, homeTabSelected, locale, lifecycle]);
    useEffect(() {
      if (!entity.pendingModelDownloadGuidance) {
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
      });
      return null;
    }, [entity.pendingModelDownloadGuidance, viewModel]);
    useEffect(
      () {
        if (!entity.pendingGemmaMeterGuidance) {
          return null;
        }
        // ホーム選択かつ前面のときだけ出す。満たさない間は pending を残す。
        if (!homeTabSelected) {
          return null;
        }
        if (lifecycle != null && lifecycle != AppLifecycleState.resumed) {
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
        });
        return null;
      },
      [entity.pendingGemmaMeterGuidance, viewModel, homeTabSelected, lifecycle],
    );
    return const TopScreenImpl();
  }
}
