import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/src/map_plugin_readiness.dart';
import 'package:infra_on_device_llm_mobile/src/on_device_llm_native_availability.dart';
import 'package:test/test.dart';

void main() {
  OnDeviceLlmNativeAvailability availability({
    required String status,
    required String reason,
  }) => OnDeviceLlmNativeAvailability(
    status: status,
    reason: reason,
    message: 'test',
  );

  test('available → ready', () {
    expect(
      mapPluginReadiness(availability(status: 'available', reason: 'ready')),
      OnDeviceLlmReadiness.ready,
    );
  });

  test('downloadable → modelNotDownloaded', () {
    expect(
      mapPluginReadiness(
        availability(status: 'downloadable', reason: 'modelNotReady'),
      ),
      OnDeviceLlmReadiness.modelNotDownloaded,
    );
  });

  test('downloading → modelNotDownloaded', () {
    expect(
      mapPluginReadiness(
        availability(status: 'downloading', reason: 'modelNotReady'),
      ),
      OnDeviceLlmReadiness.modelNotDownloaded,
    );
  });

  test('unavailable + modelNotReady → modelNotDownloaded', () {
    expect(
      mapPluginReadiness(
        availability(status: 'unavailable', reason: 'modelNotReady'),
      ),
      OnDeviceLlmReadiness.modelNotDownloaded,
    );
  });

  test('deviceNotEligible → unavailable', () {
    expect(
      mapPluginReadiness(
        availability(status: 'unavailable', reason: 'deviceNotEligible'),
      ),
      OnDeviceLlmReadiness.unavailable,
    );
  });
}
