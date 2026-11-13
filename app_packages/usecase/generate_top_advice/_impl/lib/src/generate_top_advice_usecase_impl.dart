import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

import 'conditional_advice_selector.dart';
import 'default_top_advice_prompt_builder.dart';
import 'random_advice_template_picker.dart';
import 'top_advice_llm_response_parser_impl.dart';

/// LLM または定型からワンポイントアドバイスとトーンを返す。
///
/// 履歴が空なら LLM を呼ばず未運動定型を返す。LLM 成功時は [responseParser] で
/// 本文とトーンを読む。利用不可・生成失敗・解析後に本文が空のときは [picker] で
/// 定型を選ぶ。
///
/// Example:
/// ```dart
/// GenerateTopAdviceUsecaseImpl(llm: llm);
/// ```
final class GenerateTopAdviceUsecaseImpl implements GenerateTopAdviceUsecase {
  /// [llm] と任意の [promptBuilder] / [picker] / [responseParser] を持つ実装を作る。
  ///
  /// Example:
  /// ```dart
  /// GenerateTopAdviceUsecaseImpl(llm: llm);
  /// ```
  GenerateTopAdviceUsecaseImpl({
    required this.llm,
    TopAdvicePromptBuilder? promptBuilder,
    AdviceTemplatePicker? picker,
    TopAdviceLlmResponseParser? responseParser,
    AppLogStore? log,
    this.generateTimeout = const Duration(seconds: 10),
  }) : promptBuilder = promptBuilder ?? const DefaultTopAdvicePromptBuilder(),
       picker = picker ?? RandomAdviceTemplatePicker(),
       responseParser =
           responseParser ?? const TopAdviceLlmResponseParserImpl(),
       log = log ?? AppLogStore();

  /// 端末上 LLM。
  final OnDeviceLlm llm;

  /// プロンプト組み立て。差し替え可能。
  final TopAdvicePromptBuilder promptBuilder;

  /// 定型の選択。本番は乱数。
  final AdviceTemplatePicker picker;

  /// LLM 生出力の `TONE=` / `ADVICE=` 行を [GenerateTopAdviceResult] に変換する。
  final TopAdviceLlmResponseParser responseParser;

  /// フォールバック理由などを残すログ。
  final AppLogStore log;

  /// [OnDeviceLlm.generate] の上限。超過時は定型へフォールバックする。
  final Duration generateTimeout;

  /// 空履歴 → 未運動定型（トーン付き）。それ以外は LLM を [responseParser] で
  /// 解析し、失敗時は [picker] の定型へフォールバックする。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   GenerateTopAdviceRequest(
  ///     histories: const [],
  ///     locale: 'ja',
  ///     goal: DailyGoal.unset,
  ///     consecutiveExerciseDays: 0,
  ///     noExercise: AdviceTemplate(
  ///       text: '今日はまだ運動していません',
  ///       tone: AdviceTone.realized,
  ///     ),
  ///     fallbackTemplates: const [
  ///       AdviceTemplate(text: 'a', tone: AdviceTone.fun),
  ///     ],
  ///   ),
  /// );
  /// ```
  @override
  Future<GenerateTopAdviceResult> execute(
    GenerateTopAdviceRequest request,
  ) async {
    if (request.histories.isEmpty) {
      log.append(
        tag: 'llm.advice',
        level: AppLogLevel.info,
        message: 'no histories; using no-exercise template',
      );
      return GenerateTopAdviceResult(
        advice: request.noExercise.text,
        tone: request.noExercise.tone,
      );
    }

    try {
      if (await llm.isAvailable) {
        final prompt = promptBuilder.build(
          histories: request.histories,
          locale: request.locale,
          goal: request.goal,
          consecutiveExerciseDays: request.consecutiveExerciseDays,
        );
        final generated = await llm.generate(prompt).timeout(generateTimeout);
        final parsed = responseParser.parse(generated);
        if (parsed.advice.isNotEmpty) {
          log.append(
            tag: 'llm.advice',
            level: AppLogLevel.info,
            message: 'generated advice length=${parsed.advice.length}',
          );
          return parsed;
        }
        log.append(
          tag: 'llm.advice',
          level: AppLogLevel.warn,
          message: 'parsed advice empty; falling back to template',
        );
      } else {
        log.append(
          tag: 'llm.advice',
          level: AppLogLevel.warn,
          message: 'llm not available; falling back to template',
        );
      }
    } on Object catch (error) {
      // 可否判定の失敗・生成失敗・タイムアウトは定型へフォールバックする。
      log.append(
        tag: 'llm.advice',
        level: AppLogLevel.error,
        message: 'generate failed; falling back to template: $error',
      );
    }

    final today = PeriodAggregate.of(
      request.histories,
      PeriodWindow.today(request.now),
    );
    final achievement = GoalAchievement.of(request.goal, today);
    final selection = ConditionalAdviceSelector.select(
      achievement: achievement,
      goal: request.goal,
      consecutiveGoalAchievementDays: request.consecutiveGoalAchievementDays,
      daysSincePreviousExerciseDay: request.daysSincePreviousExerciseDay,
    );
    if (selection != null) {
      final templates = request.conditionalCatalog.templatesFor(selection.kind);
      if (templates.isNotEmpty) {
        final picked = picker.pick(templates);
        final advice = _resolveMetric(
          picked.text,
          selection.metric,
          request.metricLabels,
        );
        return GenerateTopAdviceResult(advice: advice, tone: picked.tone);
      }
    }

    final picked = picker.pick(request.fallbackTemplates);
    return GenerateTopAdviceResult(advice: picked.text, tone: picked.tone);
  }

  static String _resolveMetric(
    String text,
    ConditionalAdviceMetric? metric,
    Map<ConditionalAdviceMetric, String> labels,
  ) {
    if (metric == null || !text.contains('{metric}')) {
      return text;
    }
    return text.replaceAll('{metric}', labels[metric]!);
  }
}
