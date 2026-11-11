import 'package:infra_on_device_llm/infra_on_device_llm.dart';

import 'on_device_llm_native_availability.dart';

/// ネイティブ可用性を [OnDeviceLlmReadiness] へ写す。
///
/// Example:
/// ```dart
/// mapPluginReadiness(
///   const OnDeviceLlmNativeAvailability(
///     status: 'available',
///     reason: 'ready',
///     message: 'ok',
///   ),
/// );
/// ```
OnDeviceLlmReadiness mapPluginReadiness(
  OnDeviceLlmNativeAvailability availability,
) {
  if (availability.status == 'available') {
    return OnDeviceLlmReadiness.ready;
  }
  if (availability.status == 'downloadable' ||
      availability.status == 'downloading' ||
      availability.reason == 'modelNotReady') {
    return OnDeviceLlmReadiness.modelNotDownloaded;
  }
  return OnDeviceLlmReadiness.unavailable;
}
