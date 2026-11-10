import 'package:meta/meta.dart';
import 'package:usecase_on_device_llm_guidance/usecase_on_device_llm_guidance.dart';

/// モデル準備 Usecase を呼ぶ。
///
/// Example:
/// ```dart
/// OnPrepareModelDownloadGuidanceDelegate(
///   prepareOnDeviceLlmModelUsecase: prepare,
/// ).execute();
/// ```
@internal
final class OnPrepareModelDownloadGuidanceDelegate {
  /// [prepareOnDeviceLlmModelUsecase] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnPrepareModelDownloadGuidanceDelegate(
  ///   prepareOnDeviceLlmModelUsecase: prepare,
  /// );
  /// ```
  const OnPrepareModelDownloadGuidanceDelegate({
    required this.prepareOnDeviceLlmModelUsecase,
  });

  /// モデル準備。
  final PrepareOnDeviceLlmModelUsecase prepareOnDeviceLlmModelUsecase;

  /// 準備を依頼する。例外は呼び出し側（Dialog）が掴む。
  ///
  /// Example:
  /// ```dart
  /// await delegate.execute();
  /// ```
  Future<void> execute() => prepareOnDeviceLlmModelUsecase.execute();
}
