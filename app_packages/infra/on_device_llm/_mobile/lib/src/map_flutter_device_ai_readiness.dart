import 'package:flutter_device_ai/flutter_device_ai.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';

/// [OnDeviceAiAvailability] を [OnDeviceLlmReadiness] へ写す。
///
/// Example:
/// ```dart
/// mapFlutterDeviceAiReadiness(
///   const OnDeviceAiAvailability(
///     status: ModelFeatureStatus.available,
///     reason: AvailabilityReason.ready,
///     message: 'ok',
///   ),
/// );
/// ```
OnDeviceLlmReadiness mapFlutterDeviceAiReadiness(
  OnDeviceAiAvailability availability,
) {
  if (availability.status == ModelFeatureStatus.available) {
    return OnDeviceLlmReadiness.ready;
  }
  if (availability.status == ModelFeatureStatus.downloadable ||
      availability.status == ModelFeatureStatus.downloading ||
      availability.reason == AvailabilityReason.modelNotReady) {
    return OnDeviceLlmReadiness.modelNotDownloaded;
  }
  return OnDeviceLlmReadiness.unavailable;
}
