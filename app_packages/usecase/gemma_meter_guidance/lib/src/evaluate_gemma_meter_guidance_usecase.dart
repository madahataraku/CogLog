import 'package:riverpod/riverpod.dart';

import 'gemma_meter_guidance_decision.dart';

/// Gemma 未ダウンロード誘導 (B) の要否を判定する。
///
/// Example:
/// ```dart
/// EvaluateGemmaMeterGuidanceUsecase.provider;
/// ```
abstract interface class EvaluateGemmaMeterGuidanceUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// EvaluateGemmaMeterGuidanceUsecase.provider;
  /// ```
  static final provider = Provider<EvaluateGemmaMeterGuidanceUsecase>(
    (ref) =>
        throw UnimplementedError('EvaluateGemmaMeterGuidanceUsecase.provider'),
  );

  /// 誘導対象なら [GemmaMeterGuidanceDecision.shouldShow] を true にする。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<GemmaMeterGuidanceDecision> execute();
}
