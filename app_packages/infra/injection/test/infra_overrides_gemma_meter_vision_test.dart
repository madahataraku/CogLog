import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_mobile/infra_gemma_meter_mobile.dart';
import 'package:infra_injection/infra_injection.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('android は PluginGemmaMeterVision', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(
      container.read(gemmaMeterVisionProvider),
      isA<PluginGemmaMeterVision>(),
    );
  });

  test('iOS は PluginGemmaMeterVision', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(
      container.read(gemmaMeterVisionProvider),
      isA<PluginGemmaMeterVision>(),
    );
  });

  test('linux は UnavailableGemmaMeterVision', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(
      container.read(gemmaMeterVisionProvider),
      isA<UnavailableGemmaMeterVision>(),
    );
  });
}
