import 'package:riverpod/riverpod.dart';

import 'meter_vl_guidance_decision.dart';

/// メーター VL 未ダウンロード誘導 (B) の要否を判定する。
///
/// Example:
/// ```dart
/// EvaluateMeterVlGuidanceUsecase.provider;
/// ```
abstract interface class EvaluateMeterVlGuidanceUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// EvaluateMeterVlGuidanceUsecase.provider;
  /// ```
  static final provider = Provider<EvaluateMeterVlGuidanceUsecase>(
    (ref) =>
        throw UnimplementedError('EvaluateMeterVlGuidanceUsecase.provider'),
  );

  /// 誘導対象なら [MeterVlGuidanceDecision.shouldShow] を true にする。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<MeterVlGuidanceDecision> execute();
}
