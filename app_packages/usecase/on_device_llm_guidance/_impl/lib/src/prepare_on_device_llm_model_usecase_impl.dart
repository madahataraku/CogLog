import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';

/// [OnDeviceLlm.prepareModel] へ委譲する実装。
///
/// Example:
/// ```dart
/// PrepareOnDeviceLlmModelUsecaseImpl(llm: llm);
/// ```
final class PrepareOnDeviceLlmModelUsecaseImpl
    implements PrepareOnDeviceLlmModelUsecase {
  /// [llm] を使う実装を作る。
  ///
  /// Example:
  /// ```dart
  /// PrepareOnDeviceLlmModelUsecaseImpl(llm: llm);
  /// ```
  PrepareOnDeviceLlmModelUsecaseImpl({required this.llm});

  /// 端末上 LLM。
  final OnDeviceLlm llm;

  /// [OnDeviceLlm.prepareModel] へ委譲する。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  @override
  Future<void> execute() => llm.prepareModel();
}
