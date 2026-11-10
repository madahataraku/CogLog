import 'package:infra_on_device_llm/infra_on_device_llm.dart';

/// 端末上 LLM の診断結果。
///
/// Example:
/// ```dart
/// DiagnoseOnDeviceLlmResult(
///   snapshot: const OnDeviceLlmAvailabilitySnapshot(
///     readiness: OnDeviceLlmReadiness.ready,
///     status: 'available',
///     reason: 'ready',
///     message: 'ok',
///   ),
///   canGenerate: true,
///   sampleOutput: 'hello',
/// );
/// ```
final class DiagnoseOnDeviceLlmResult {
  /// スナップショットと生成プローブ結果を持つ。
  ///
  /// Example:
  /// ```dart
  /// DiagnoseOnDeviceLlmResult(
  ///   snapshot: const OnDeviceLlmAvailabilitySnapshot(
  ///     readiness: OnDeviceLlmReadiness.ready,
  ///     status: 'available',
  ///     reason: 'ready',
  ///     message: 'ok',
  ///   ),
  ///   canGenerate: false,
  ///   generateError: 'timeout',
  /// );
  /// ```
  const DiagnoseOnDeviceLlmResult({
    required this.snapshot,
    required this.canGenerate,
    this.sampleOutput,
    this.generateError,
    this.probeSkippedReason,
  });

  /// availability の詳細。
  final OnDeviceLlmAvailabilitySnapshot snapshot;

  /// 生成プローブが本文を返したとき true。
  final bool canGenerate;

  /// 生成プローブの本文。
  final String? sampleOutput;

  /// 生成プローブの例外文字列。
  final String? generateError;

  /// 生成を試さなかった理由（未 ready など）。
  final String? probeSkippedReason;
}
