import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';
import 'package:usecase_gemma_meter_guidance/usecase_gemma_meter_guidance.dart';
import 'package:usecase_load_top_screen/usecase_load_top_screen.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';
import 'package:view_model_download_guidance/view_model_download_guidance.dart';

import '../state/top_screen_state.dart';
import 'on_evaluate_gemma_meter_guidance_delegate.dart';

/// トップ画面の期間合計とアドバイスを読み、State を置き換える。
///
/// Example:
/// ```dart
/// OnInitializeDelegate(
///   state: state,
///   loadTopScreenUsecase: loadTopScreenUsecase,
///   generateTopAdviceUsecase: generateTopAdviceUsecase,
///   evaluateOnDeviceLlmGuidanceUsecase: evaluateOnDeviceLlmGuidanceUsecase,
///   evaluateGemmaMeterGuidanceUsecase: evaluateGemmaMeterGuidanceUsecase,
///   guidanceSession: guidanceSession,
///   gemmaSession: gemmaSession,
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
  ///   evaluateGemmaMeterGuidanceUsecase: evaluateGemmaMeterGuidanceUsecase,
  ///   guidanceSession: guidanceSession,
  ///   gemmaSession: gemmaSession,
  /// );
  /// ```
  const OnInitializeDelegate({
    required this.state,
    required this.loadTopScreenUsecase,
    required this.generateTopAdviceUsecase,
    required this.evaluateOnDeviceLlmGuidanceUsecase,
    required this.evaluateGemmaMeterGuidanceUsecase,
    required this.guidanceSession,
    required this.gemmaSession,
  });

  /// 更新する画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 期間合計の読み込み。
  final LoadTopScreenUsecase loadTopScreenUsecase;

  /// ワンポイントアドバイスの生成。
  final GenerateTopAdviceUsecase generateTopAdviceUsecase;

  /// OS LLM モデル未ダウンロード誘導 (A) の要否。
  final EvaluateOnDeviceLlmGuidanceUsecase evaluateOnDeviceLlmGuidanceUsecase;

  /// Gemma メーター誘導 (B) の要否。
  final EvaluateGemmaMeterGuidanceUsecase evaluateGemmaMeterGuidanceUsecase;

  /// プロセス内の (A) 誘導再表示抑制。
  final OnDeviceLlmGuidanceSession guidanceSession;

  /// プロセス内の (B) 誘導再表示抑制。
  final GemmaMeterGuidanceSession gemmaSession;

  /// 期間合計とアドバイスを先に出し、誘導判定は後から反映する。
  ///
  /// (A) を出さないときだけ、ここで (B) を評価する。(A) を出すときは
  /// ダイアログ完了後に [OnEvaluateGemmaMeterGuidanceDelegate] を呼ぶ。
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
          pendingGemmaMeterGuidance: false,
          hasNewAchievements: result.hasNewAchievements,
        ),
      );
    });

    var pendingA = false;
    if (guidanceSession.shouldShow) {
      final decision = await evaluateOnDeviceLlmGuidanceUsecase.execute();
      if (decision.shouldShow && guidanceSession.shouldShow) {
        await state.updateWithLock((current, emitter) async {
          if (!guidanceSession.shouldShow) {
            return;
          }
          pendingA = true;
          await emitter.emit(
            current.copyWith(pendingModelDownloadGuidance: true),
          );
        });
      }
    }

    // (A) を出さない場合は Ready 後すぐ (B) を評価する。
    if (!pendingA) {
      await OnEvaluateGemmaMeterGuidanceDelegate(
        state: state,
        evaluateGemmaMeterGuidanceUsecase: evaluateGemmaMeterGuidanceUsecase,
        gemmaSession: gemmaSession,
      ).execute();
    }
  }
}
