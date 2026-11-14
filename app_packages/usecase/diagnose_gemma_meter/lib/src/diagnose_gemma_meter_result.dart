import 'package:infra_gemma_meter/infra_gemma_meter.dart';

/// Gemma メーター経路の診断結果（測定値・生文なし）。
///
/// Example:
/// ```dart
/// DiagnoseGemmaMeterResult(
///   snapshot: const GemmaMeterAvailabilitySnapshot(
///     readiness: GemmaMeterReadiness.ready,
///     status: 'available',
///     reason: 'ready',
///     message: 'ok',
///   ),
///   canGenerate: true,
///   probeOutputLength: 2,
/// );
/// ```
final class DiagnoseGemmaMeterResult {
  /// スナップショットと準備／画像プローブ結果を持つ。
  ///
  /// Example:
  /// ```dart
  /// DiagnoseGemmaMeterResult(
  ///   snapshot: const GemmaMeterAvailabilitySnapshot(
  ///     readiness: GemmaMeterReadiness.unavailable,
  ///     status: 'error',
  ///     reason: 'exception',
  ///     message: 'availabilitySnapshot failed',
  ///   ),
  ///   canGenerate: false,
  ///   availabilityError: 'StateError: boom',
  ///   generateError: 'StateError: generate failed',
  ///   prepareError: 'StateError: prepare failed',
  /// );
  /// ```
  const DiagnoseGemmaMeterResult({
    required this.snapshot,
    required this.canGenerate,
    this.availabilityError,
    this.probeOutputLength,
    this.generateError,
    this.prepareError,
    this.probeSkippedReason,
  });

  /// availability の詳細。
  final GemmaMeterAvailabilitySnapshot snapshot;

  /// 画像プローブが非空本文を返したとき true（本文自体は保持しない）。
  final bool canGenerate;

  /// 利用可否取得で捕捉した例外（型名付き）。無ければ null。
  final String? availabilityError;

  /// プローブ本文の文字数。未実行・失敗時は null。
  final int? probeOutputLength;

  /// 画像プローブの例外（型名付き）。
  final String? generateError;

  /// 準備プローブの例外（型名付き）。
  final String? prepareError;

  /// プローブを試さなかった理由（probeGenerate=false など）。
  final String? probeSkippedReason;
}
