import 'package:riverpod/riverpod.dart';

import 'meter_vl_guidance_session.dart';
import 'on_device_llm_guidance_session.dart';

/// モデル誘導 UI 用の Provider 束。(A)/(B) セッションを分ける。
///
/// Example:
/// ```dart
/// ModelDownloadGuidanceProviders.session;
/// ModelDownloadGuidanceProviders.meterVlSession;
/// ```
final class ModelDownloadGuidanceProviders {
  /// プロセス内の (A) 再表示抑制セッション。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(ModelDownloadGuidanceProviders.session);
  /// ```
  static final session = Provider<OnDeviceLlmGuidanceSession>(
    (ref) => OnDeviceLlmGuidanceSession(),
  );

  /// プロセス内の (B) メーター VL 再表示抑制セッション。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(ModelDownloadGuidanceProviders.meterVlSession);
  /// ```
  static final meterVlSession = Provider<MeterVlGuidanceSession>(
    (ref) => MeterVlGuidanceSession(),
  );

  const ModelDownloadGuidanceProviders._();
}
