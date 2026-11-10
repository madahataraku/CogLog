import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_injection/infra_injection.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/infra_on_device_llm_mobile.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('android は FlutterDeviceAiOnDeviceLlm', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(
      container.read(onDeviceLlmProvider),
      isA<FlutterDeviceAiOnDeviceLlm>(),
    );
  });

  test('iOS は FlutterDeviceAiOnDeviceLlm', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(
      container.read(onDeviceLlmProvider),
      isA<FlutterDeviceAiOnDeviceLlm>(),
    );
  });

  test('linux は UnavailableOnDeviceLlm', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(container.read(onDeviceLlmProvider), isA<UnavailableOnDeviceLlm>());
  });
}
