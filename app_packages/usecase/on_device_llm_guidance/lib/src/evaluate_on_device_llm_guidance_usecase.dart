import 'package:riverpod/riverpod.dart';

import 'on_device_llm_guidance_decision.dart';

/// モデル未ダウンロード誘導の要否を判定する。
///
/// Example:
/// ```dart
/// EvaluateOnDeviceLlmGuidanceUsecase.provider;
/// ```
abstract interface class EvaluateOnDeviceLlmGuidanceUsecase {
  /// 未接続のときは失敗する注入点。
  ///
  /// Example:
  /// ```dart
  /// EvaluateOnDeviceLlmGuidanceUsecase.provider;
  /// ```
  static final provider = Provider<EvaluateOnDeviceLlmGuidanceUsecase>(
    (ref) =>
        throw UnimplementedError('EvaluateOnDeviceLlmGuidanceUsecase.provider'),
  );

  /// 誘導対象なら [OnDeviceLlmGuidanceDecision.shouldShow] を true にする。
  ///
  /// Example:
  /// ```dart
  /// await usecase.execute();
  /// ```
  Future<OnDeviceLlmGuidanceDecision> execute();
}
