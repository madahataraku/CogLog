import 'package:riverpod/riverpod.dart';

import 'on_device_llm_guidance_session.dart';

/// モデル誘導 UI 用の Provider 束。
///
/// Example:
/// ```dart
/// ModelDownloadGuidanceProviders.session;
/// ```
final class ModelDownloadGuidanceProviders {
  /// プロセス内の再表示抑制セッション。
  ///
  /// Example:
  /// ```dart
  /// ref.watch(ModelDownloadGuidanceProviders.session);
  /// ```
  static final session = Provider<OnDeviceLlmGuidanceSession>(
    (ref) => OnDeviceLlmGuidanceSession(),
  );

  const ModelDownloadGuidanceProviders._();
}
