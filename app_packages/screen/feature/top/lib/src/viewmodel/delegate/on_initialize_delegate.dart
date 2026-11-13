import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/top_screen_state.dart';

/// トップ画面の期間合計とアドバイスを読み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadTopScreenUsecase: loadTopScreenUsecase,
///   generateTopAdviceUsecase: generateTopAdviceUsecase,
///   evaluateOnDeviceLlmGuidanceUsecase: evaluateOnDeviceLlmGuidanceUsecase,
///   guidanceSession: guidanceSession,
/// ).execute(
///   locale: 'ja',
///   noExercise: AdviceTemplate(
///     text: '今日はまだ運動していません',
///     tone: AdviceTone.realized,
///   ),
///   fallbackTemplates: const [
///     AdviceTemplate(text: 'a', tone: AdviceTone.fun),
///   ],
/// );
/// ```
@internal
final class OnInitializeDelegate {
  /// [state] と読み込み・アドバイス生成・誘導判定を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnInitializeDelegate(
  ///   state: state,
  ///   loadTopScreenUsecase: loadTopScreenUsecase,
  ///   generateTopAdviceUsecase: generateTopAdviceUsecase,
  ///   evaluateOnDeviceLlmGuidanceUsecase: evaluateOnDeviceLlmGuidanceUsecase,
  ///   guidanceSession: guidanceSession,
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.loadTopScreenUsecase,
    required this.generateTopAdviceUsecase,
    required this.evaluateOnDeviceLlmGuidanceUsecase,
    required this.guidanceSession,
  });

  /// 更新する画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 期間合計の読み込み。
  final LoadTopScreenUsecase loadTopScreenUsecase;

  /// ワンポイントアドバイスの生成。
  final GenerateTopAdviceUsecase generateTopAdviceUsecase;

  /// モデル未ダウンロード誘導の要否。
  final EvaluateOnDeviceLlmGuidanceUsecase evaluateOnDeviceLlmGuidanceUsecase;

  /// プロセス内の誘導再表示抑制。
  final OnDeviceLlmGuidanceSession guidanceSession;

  /// 期間合計とアドバイスを先に出し、誘導判定は後から反映する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(
  ///   locale: 'ja',
  ///   noExercise: AdviceTemplate(
  ///     text: '今日はまだ運動していません',
  ///     tone: AdviceTone.realized,
  ///   ),
  ///   fallbackTemplates: const [
  ///     AdviceTemplate(text: 'a', tone: AdviceTone.fun),
  ///   ],
  /// );
  /// ```
  Future<void> execute({
    required String locale,
    required AdviceTemplate noExercise,
    required List<AdviceTemplate> fallbackTemplates,
    required ConditionalAdviceCatalog conditionalCatalog,
    required Map<ConditionalAdviceMetric, String> metricLabels,
  }) async {
    await state.updateWithLock((_, emitter) async {
      final now = DateTime.now();
      final result = await loadTopScreenUsecase.execute(
        LoadTopScreenRequest(now: now),
      );
      final advice = await generateTopAdviceUsecase.execute(
        GenerateTopAdviceRequest(
          histories: result.todayHistories,
          locale: locale,
          now: now,
          goal: result.goal,
          consecutiveExerciseDays: result.consecutiveExerciseDays,
          consecutiveGoalAchievementDays: result.consecutiveGoalAchievementDays,
          daysSincePreviousExerciseDay: result.daysSincePreviousExerciseDay,
          noExercise: noExercise,
          conditionalCatalog: conditionalCatalog,
          metricLabels: metricLabels,
          fallbackTemplates: fallbackTemplates,
        ),
      );
      // 期間合計と助言は誘導判定を待たず先に出す。
      await emitter.emit(
        TopScreenState(
          loaded: true,
          metric: result.metric,
          today: result.today,
          week: result.week,
          month: result.month,
          goal: result.goal,
          adviceText: advice.advice,
          adviceTone: advice.tone,
          pendingModelDownloadGuidance: false,
          hasNewAchievements: result.hasNewAchievements,
        ),
      );
    });

    if (!guidanceSession.shouldShow) {
      return;
    }
    final decision = await evaluateOnDeviceLlmGuidanceUsecase.execute();
    if (!decision.shouldShow || !guidanceSession.shouldShow) {
      return;
    }
    await state.updateWithLock((current, emitter) async {
      if (!guidanceSession.shouldShow) {
        return;
      }
      await emitter.emit(
        TopScreenState(
          loaded: current.loaded,
          metric: current.metric,
          today: current.today,
          week: current.week,
          month: current.month,
          goal: current.goal,
          adviceText: current.adviceText,
          adviceTone: current.adviceTone,
          pendingModelDownloadGuidance: true,
          hasNewAchievements: current.hasNewAchievements,
        ),
      );
    });
  }
}
