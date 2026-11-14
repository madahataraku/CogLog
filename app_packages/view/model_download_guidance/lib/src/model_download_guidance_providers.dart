import 'package:riverpod/riverpod.dart';

import 'gemma_meter_guidance_session.dart';
import 'on_device_llm_guidance_session.dart';

/// モデル誘導 UI 用の Provider 束。(A)/(B) セッションを分ける。
///
/// Example:
/// ```dart
/// ModelDownloadGuidanceProviders.session;
/// ModelDownloadGuidanceProviders.gemmaSession;
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

  /// プロセス内の (B) Gemma 再表示抑制セッション。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(ModelDownloadGuidanceProviders.gemmaSession);
  /// ```
  static final gemmaSession = Provider<GemmaMeterGuidanceSession>(
    (ref) => GemmaMeterGuidanceSession(),
  );

  const ModelDownloadGuidanceProviders._();
}
