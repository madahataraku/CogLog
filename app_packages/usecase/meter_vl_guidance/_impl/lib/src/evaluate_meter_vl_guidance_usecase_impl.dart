import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_meter_vl_guidance/usecase_meter_vl_guidance.dart';

/// OS LLM とメーター VL の準備状態から (B) 誘導要否を決める実装。
///
/// Example:
/// ```dart
/// EvaluateMeterVlGuidanceUsecaseImpl(llm: llm, meterVl: meterVl);
/// ```
final class EvaluateMeterVlGuidanceUsecaseImpl
    implements EvaluateMeterVlGuidanceUsecase {
  /// [llm] と [meterVl] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// EvaluateMeterVlGuidanceUsecaseImpl(llm: llm, meterVl: meterVl);
  /// ```
  EvaluateMeterVlGuidanceUsecaseImpl({
    required this.llm,
    required this.meterVl,
  });

  /// 端末上 OS LLM。
  final OnDeviceLlm llm;

  /// メーター VL経路。
  final MeterVlVision meterVl;

  /// (A) 不成立かつメーター向け OS LLM 不可かつ メーター VL 未ダウンロードのときだけ
  /// [MeterVlGuidanceDecision.shouldShow] を true にする。
  /// 可否取得に失敗したときは false とする。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<MeterVlGuidanceDecision> execute() async {
    try {
      final llmReadiness = await llm.readiness;
      // (A) が成立するときは (B) の対象外。
      if (llmReadiness == OnDeviceLlmReadiness.modelNotDownloaded) {
        return const MeterVlGuidanceDecision(shouldShow: false);
      }

      final supportsVision = await llm.supportsVision;
      final osUnusableForMeter =
          llmReadiness == OnDeviceLlmReadiness.unavailable || !supportsVision;
      if (!osUnusableForMeter) {
        return const MeterVlGuidanceDecision(shouldShow: false);
      }

      final meterVlReadiness = await meterVl.readiness;
      return MeterVlGuidanceDecision(
        shouldShow: meterVlReadiness == MeterVlReadiness.modelNotDownloaded,
      );
    } on Object {
      // 可否取得の失敗は誘導対象外とする。
      return const MeterVlGuidanceDecision(shouldShow: false);
    }
  }
}
