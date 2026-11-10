import 'package:flutter_device_ai/flutter_device_ai.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/src/map_flutter_device_ai_readiness.dart';
import 'package:test/test.dart';

void main() {
  OnDeviceAiAvailability availability({
    required ModelFeatureStatus status,
    required AvailabilityReason reason,
  }) => OnDeviceAiAvailability(status: status, reason: reason, message: 'test');

  test('available → ready', () {
    expect(
      mapFlutterDeviceAiReadiness(
        availability(
          status: ModelFeatureStatus.available,
          reason: AvailabilityReason.ready,
        ),
      ),
      OnDeviceLlmReadiness.ready,
    );
  });

  test('downloadable → modelNotDownloaded', () {
    expect(
      mapFlutterDeviceAiReadiness(
        availability(
          status: ModelFeatureStatus.downloadable,
          reason: AvailabilityReason.modelNotReady,
        ),
      ),
      OnDeviceLlmReadiness.modelNotDownloaded,
    );
  });

  test('downloading → modelNotDownloaded', () {
    expect(
      mapFlutterDeviceAiReadiness(
        availability(
          status: ModelFeatureStatus.downloading,
          reason: AvailabilityReason.modelNotReady,
        ),
      ),
      OnDeviceLlmReadiness.modelNotDownloaded,
    );
  });

  test('unavailable + modelNotReady → modelNotDownloaded', () {
    expect(
      mapFlutterDeviceAiReadiness(
        availability(
          status: ModelFeatureStatus.unavailable,
          reason: AvailabilityReason.modelNotReady,
        ),
      ),
      OnDeviceLlmReadiness.modelNotDownloaded,
    );
  });

  test('deviceNotEligible → unavailable', () {
    expect(
      mapFlutterDeviceAiReadiness(
        availability(
          status: ModelFeatureStatus.unavailable,
          reason: AvailabilityReason.deviceNotEligible,
        ),
      ),
      OnDeviceLlmReadiness.unavailable,
    );
  });
}
