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
  ///   generateError: 'StateError: timeout',
  ///   prepareError: 'StateError: prepare failed',
  /// );
  /// ```
  const DiagnoseOnDeviceLlmResult({
    required this.snapshot,
    required this.canGenerate,
    this.sampleOutput,
    this.generateError,
    this.prepareError,
    this.probeSkippedReason,
  });

  /// availability の詳細。
  final OnDeviceLlmAvailabilitySnapshot snapshot;

  /// 生成プローブが本文を返したとき true。
  final bool canGenerate;

  /// 生成プローブの本文。
  final String? sampleOutput;

  /// 生成プローブの例外（型名付き）。
  final String? generateError;

  /// 準備プローブの例外（型名付き）。
  final String? prepareError;

  /// 生成を試さなかった理由（probeGenerate=false など）。
  final String? probeSkippedReason;
}
