import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';

/// [OnDeviceLlm] の準備状態から誘導要否を決める実装。
///
/// Example:
/// ```dart
/// EvaluateOnDeviceLlmGuidanceUsecaseImpl(llm: llm);
/// ```
final class EvaluateOnDeviceLlmGuidanceUsecaseImpl
    implements EvaluateOnDeviceLlmGuidanceUsecase {
  /// [llm] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// EvaluateOnDeviceLlmGuidanceUsecaseImpl(llm: llm);
  /// ```
  EvaluateOnDeviceLlmGuidanceUsecaseImpl({required this.llm});

  /// 端末上 LLM。
  final OnDeviceLlm llm;

  /// 未ダウンロードのときだけ [OnDeviceLlmGuidanceDecision.shouldShow] を true にする。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<OnDeviceLlmGuidanceDecision> execute() async {
    try {
      final readiness = await llm.readiness;
      return OnDeviceLlmGuidanceDecision(
        shouldShow: readiness == OnDeviceLlmReadiness.modelNotDownloaded,
      );
    } on Object {
      // 可否取得の失敗は誘導対象外とし、業務フォールバックのみにする。
      return const OnDeviceLlmGuidanceDecision(shouldShow: false);
    }
  }
}
