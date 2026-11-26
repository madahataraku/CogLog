import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_mobile/infra_meter_vl_mobile.dart';
import 'package:infra_injection/infra_injection.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('android は PluginMeterVlVision', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(container.read(meterVlVisionProvider), isA<PluginMeterVlVision>());
  });

  test('iOS は PluginMeterVlVision', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(container.read(meterVlVisionProvider), isA<PluginMeterVlVision>());
  });

  test('linux は UnavailableMeterVlVision', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    expect(
      container.read(meterVlVisionProvider),
      isA<UnavailableMeterVlVision>(),
    );
  });
}
