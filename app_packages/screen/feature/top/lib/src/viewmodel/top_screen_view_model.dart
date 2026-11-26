import 'dart:async';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';
import 'package:usecase_load_achievements/usecase_load_achievements.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import 'delegate/on_acknowledge_meter_vl_guidance_delegate.dart';
import 'delegate/on_acknowledge_model_download_guidance_delegate.dart';
import 'delegate/on_acknowledge_tutorial_achievement_delegate.dart';
import 'delegate/on_acknowledge_tutorial_main_delegate.dart';
import 'delegate/on_advance_tutorial_main_delegate.dart';
import 'delegate/on_dismiss_tutorial_achievement_delegate.dart';
import 'delegate/on_evaluate_meter_vl_guidance_delegate.dart';
import 'delegate/on_evaluate_tutorial_achievement_delegate.dart';
import 'delegate/on_evaluate_tutorial_main_delegate.dart';
import 'delegate/on_initialize_delegate.dart';
import 'delegate/on_open_achievements_delegate.dart';
import 'delegate/on_open_app_settings_delegate.dart';
import 'delegate/on_park_tutorial_main_delegate.dart';
import 'delegate/on_prepare_meter_vl_guidance_delegate.dart';
import 'delegate/on_prepare_model_download_guidance_delegate.dart';
import 'delegate/on_select_metric_delegate.dart';
import 'delegate/top_screen_state_to_entity_delegate.dart';
import 'entity/top_screen_entity.dart';
import 'state/top_screen_state.dart';

part 'top_screen_view_model.action.dart';

/// トップ画面の状態と表示。
///
/// 可変な値は [state] だけが持つ。
///
/// Example:
/// ```dart
/// TopScreenViewModel.provider;
/// ```
@internal
final class TopScreenViewModel {
  /// 読み込みと保存・アドバイス生成・誘導の Usecase を注入して作る。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(TopScreenViewModel.provider);
  /// ```
  static final provider = Provider.autoDispose<TopScreenViewModel>(
    (ref) {
      ref.watch(appDataImportRefreshProvider);
      final result = TopScreenViewModel._(
        state: MutableStateStream(TopScreenState.initial),
        loadTopScreenUsecase: ref.watch(LoadTopScreenUsecase.provider),
        saveTopScreenMetricUsecase: ref.watch(
          SaveTopScreenMetricUsecase.provider,
        ),
        generateTopAdviceUsecase: ref.watch(GenerateTopAdviceUsecase.provider),
        evaluateOnDeviceLlmGuidanceUsecase: ref.watch(
          EvaluateOnDeviceLlmGuidanceUsecase.provider,
        ),
        prepareOnDeviceLlmModelUsecase: ref.watch(
          PrepareOnDeviceLlmModelUsecase.provider,
        ),
        evaluateMeterVlGuidanceUsecase: ref.watch(
          EvaluateMeterVlGuidanceUsecase.provider,
        ),
        prepareMeterVlModelUsecase: ref.watch(
          PrepareMeterVlModelUsecase.provider,
        ),
        guidanceSession: ref.watch(ModelDownloadGuidanceProviders.session),
        meterVlSession: ref.watch(
          ModelDownloadGuidanceProviders.meterVlSession,
        ),
        navigation: ref.watch(screenNavigationProvider),
        newIndicator: ref.watch(LoadAchievementNewIndicatorUsecase.provider),
        evaluateTutorialMainAutoStartUsecase: ref.watch(
          EvaluateTutorialMainAutoStartUsecase.provider,
        ),
        advanceTutorialMainUsecase: ref.watch(
          AdvanceTutorialMainUsecase.provider,
        ),
        evaluateTutorialContextUsecase: ref.watch(
          EvaluateTutorialContextUsecase.provider,
        ),
        markTutorialContextSeenUsecase: ref.watch(
          MarkTutorialContextSeenUsecase.provider,
        ),
        loadAchievementsUsecase: ref.watch(LoadAchievementsUsecase.provider),
        tutorialSession: ref.watch(tutorialRuntimeSessionProvider),
        stateToEntity: const TopScreenStateToEntityDelegate(),
        now: DateTime.now,
      );
      ref.onDispose(() {
        unawaited(result._close());
      });
      return result;
    },
    dependencies: [
      appDataImportRefreshProvider,
      LoadTopScreenUsecase.provider,
      SaveTopScreenMetricUsecase.provider,
      GenerateTopAdviceUsecase.provider,
      EvaluateOnDeviceLlmGuidanceUsecase.provider,
      PrepareOnDeviceLlmModelUsecase.provider,
      EvaluateMeterVlGuidanceUsecase.provider,
      PrepareMeterVlModelUsecase.provider,
      ModelDownloadGuidanceProviders.session,
      ModelDownloadGuidanceProviders.meterVlSession,
      screenNavigationProvider,
      LoadAchievementNewIndicatorUsecase.provider,
      EvaluateTutorialMainAutoStartUsecase.provider,
      AdvanceTutorialMainUsecase.provider,
      EvaluateTutorialContextUsecase.provider,
      MarkTutorialContextSeenUsecase.provider,
      LoadAchievementsUsecase.provider,
      tutorialRuntimeSessionProvider,
    ],
  );

  /// 画面状態。
  @visibleForTesting
  final MutableStateStream<TopScreenState> state;

  /// 期間合計の読み込み。
  @visibleForTesting
  final LoadTopScreenUsecase loadTopScreenUsecase;

  /// 指標の保存。
  @visibleForTesting
  final SaveTopScreenMetricUsecase saveTopScreenMetricUsecase;

  /// ワンポイントアドバイスの生成。
  @visibleForTesting
  final GenerateTopAdviceUsecase generateTopAdviceUsecase;

  /// OS LLM モデル未ダウンロード誘導 (A) の要否。
  @visibleForTesting
  final EvaluateOnDeviceLlmGuidanceUsecase evaluateOnDeviceLlmGuidanceUsecase;

  /// OS LLM モデル準備。
  @visibleForTesting
  final PrepareOnDeviceLlmModelUsecase prepareOnDeviceLlmModelUsecase;

  /// メーター VL誘導 (B) の要否。
  @visibleForTesting
  final EvaluateMeterVlGuidanceUsecase evaluateMeterVlGuidanceUsecase;

  /// メーター VL モデル準備。
  @visibleForTesting
  final PrepareMeterVlModelUsecase prepareMeterVlModelUsecase;

  /// プロセス内の (A) 誘導再表示抑制。
  @visibleForTesting
  final OnDeviceLlmGuidanceSession guidanceSession;

  /// プロセス内の (B) 誘導再表示抑制。
  @visibleForTesting
  final MeterVlGuidanceSession meterVlSession;

  /// 画面遷移。
  @visibleForTesting
  final ScreenNavigation navigation;

  /// 新規アチーブメント有無。
  @visibleForTesting
  final LoadAchievementNewIndicatorUsecase newIndicator;

  /// メイン自動開始判定。
  @visibleForTesting
  final EvaluateTutorialMainAutoStartUsecase
  evaluateTutorialMainAutoStartUsecase;

  /// メイン段階進行。
  @visibleForTesting
  final AdvanceTutorialMainUsecase advanceTutorialMainUsecase;

  /// 文脈判定。
  @visibleForTesting
  final EvaluateTutorialContextUsecase evaluateTutorialContextUsecase;

  /// 文脈表示済み。
  @visibleForTesting
  final MarkTutorialContextSeenUsecase markTutorialContextSeenUsecase;

  /// アチーブメント一覧（文脈の獲得件数）。
  @visibleForTesting
  final LoadAchievementsUsecase loadAchievementsUsecase;

  /// プロセス内チュートリアル状態。
  @visibleForTesting
  final TutorialRuntimeSession tutorialSession;

  /// State から表示文字列への変換。
  @visibleForTesting
  final TopScreenStateToEntityDelegate stateToEntity;

  /// 新規判定の基準時刻。
  @visibleForTesting
  final DateTime Function() now;

  /// 注入された依存から ViewModel を作る。
  ///
  /// Example:
  /// ```dart
  /// TopScreenViewModel.provider;
  /// ```
  const TopScreenViewModel._({
    required this.state,
    required this.loadTopScreenUsecase,
    required this.saveTopScreenMetricUsecase,
    required this.generateTopAdviceUsecase,
    required this.evaluateOnDeviceLlmGuidanceUsecase,
    required this.prepareOnDeviceLlmModelUsecase,
    required this.evaluateMeterVlGuidanceUsecase,
    required this.prepareMeterVlModelUsecase,
    required this.guidanceSession,
    required this.meterVlSession,
    required this.navigation,
    required this.newIndicator,
    required this.evaluateTutorialMainAutoStartUsecase,
    required this.advanceTutorialMainUsecase,
    required this.evaluateTutorialContextUsecase,
    required this.markTutorialContextSeenUsecase,
    required this.loadAchievementsUsecase,
    required this.tutorialSession,
    required this.stateToEntity,
    required this.now,
  });

  /// 表示に使う文字列。
  StateStream<TopScreenEntity> get entity => state.map(stateToEntity.execute);

  /// 状態の Stream を閉じる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.provider;
  /// ```
  Future<void> _close() => state.close();
}
