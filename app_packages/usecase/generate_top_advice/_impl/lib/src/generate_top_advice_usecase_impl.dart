import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_generate_top_advice/usecase_generate_top_advice.dart';

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
    this.generateTimeout = const Duration(seconds: 10),
  }) : promptBuilder = promptBuilder ?? const DefaultTopAdvicePromptBuilder(),
       picker = picker ?? RandomAdviceTemplatePicker(),
       responseParser =
           responseParser ?? const TopAdviceLlmResponseParserImpl();

  /// 端末上 LLM。
  final OnDeviceLlm llm;

  /// プロンプト組み立て。差し替え可能。
  final TopAdvicePromptBuilder promptBuilder;

  /// 定型の選択。本番は乱数。
  final AdviceTemplatePicker picker;

  /// LLM 生出力の `TONE=` / `ADVICE=` 行を [GenerateTopAdviceResult] に変換する。
  final TopAdviceLlmResponseParser responseParser;

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
        );
        final generated = await llm.generate(prompt).timeout(generateTimeout);
        final parsed = responseParser.parse(generated);
        if (parsed.advice.isNotEmpty) {
          return parsed;
        }
      }
    } on Object {
      // 可否判定の失敗・生成失敗・タイムアウトは定型へフォールバックする。
    }

    final picked = picker.pick(request.fallbackTemplates);
    return GenerateTopAdviceResult(advice: picked.text, tone: picked.tone);
  }
}
