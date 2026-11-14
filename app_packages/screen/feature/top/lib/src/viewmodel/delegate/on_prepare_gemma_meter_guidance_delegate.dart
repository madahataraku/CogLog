import 'package:meta/meta.dart';
import 'package:usecase_gemma_meter_guidance/usecase_gemma_meter_guidance.dart';

/// Gemma モデル準備 Usecase を呼ぶ。
///
/// Example:
/// ```dart
/// OnPrepareGemmaMeterGuidanceDelegate(
///   prepareGemmaMeterModelUsecase: prepare,
/// ).execute();
/// ```
@internal
final class OnPrepareGemmaMeterGuidanceDelegate {
  /// [prepareGemmaMeterModelUsecase] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnPrepareGemmaMeterGuidanceDelegate(
  ///   prepareGemmaMeterModelUsecase: prepare,
  /// );
  /// ```
  const OnPrepareGemmaMeterGuidanceDelegate({
    required this.prepareGemmaMeterModelUsecase,
  });

  /// Gemma モデル準備。
  final PrepareGemmaMeterModelUsecase prepareGemmaMeterModelUsecase;

  /// 準備進捗を流す。例外は呼び出し側（Dialog）が掴む。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in delegate.execute()) {
  ///   progress;
  /// }
  /// ```
  Stream<double> execute() => prepareGemmaMeterModelUsecase.execute();
}
