import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_gemma_meter_guidance/usecase_gemma_meter_guidance.dart';

/// OS LLM と Gemma の準備状態から (B) 誘導要否を決める実装。
///
/// Example:
/// ```dart
/// EvaluateGemmaMeterGuidanceUsecaseImpl(llm: llm, gemma: gemma);
/// ```
final class EvaluateGemmaMeterGuidanceUsecaseImpl
    implements EvaluateGemmaMeterGuidanceUsecase {
  /// [llm] と [gemma] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// EvaluateGemmaMeterGuidanceUsecaseImpl(llm: llm, gemma: gemma);
  /// ```
  EvaluateGemmaMeterGuidanceUsecaseImpl({
    required this.llm,
    required this.gemma,
  });

  /// 端末上 OS LLM。
  final OnDeviceLlm llm;

  /// Gemma メーター経路。
  final GemmaMeterVision gemma;

  /// (A) 不成立かつメーター向け OS LLM 不可かつ Gemma 未ダウンロードのときだけ
  /// [GemmaMeterGuidanceDecision.shouldShow] を true にする。
  /// 可否取得に失敗したときは false とする。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<GemmaMeterGuidanceDecision> execute() async {
    try {
      final llmReadiness = await llm.readiness;
      // (A) が成立するときは (B) の対象外。
      if (llmReadiness == OnDeviceLlmReadiness.modelNotDownloaded) {
        return const GemmaMeterGuidanceDecision(shouldShow: false);
      }

      final supportsVision = await llm.supportsVision;
      final osUnusableForMeter =
          llmReadiness == OnDeviceLlmReadiness.unavailable || !supportsVision;
      if (!osUnusableForMeter) {
        return const GemmaMeterGuidanceDecision(shouldShow: false);
      }

      final gemmaReadiness = await gemma.readiness;
      return GemmaMeterGuidanceDecision(
        shouldShow: gemmaReadiness == GemmaMeterReadiness.modelNotDownloaded,
      );
    } on Object {
      // 可否取得の失敗は誘導対象外とする。
      return const GemmaMeterGuidanceDecision(shouldShow: false);
    }
  }
}
