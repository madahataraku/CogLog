import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_injection/infra_injection.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('iOS は foundationModel のみ', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    final engines = container.read(meterReadingEnginesProvider);
    expect(engines.map((e) => e.kind).toList(), [
      MeterReadingEngineKind.foundationModel,
    ]);
    expect(engines.single, isA<LlmMeterReadingEngine>());
  });

  test('Android は geminiNano のみ', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    final engines = container.read(meterReadingEnginesProvider);
    expect(engines.map((e) => e.kind).toList(), [
      MeterReadingEngineKind.geminiNano,
    ]);
    expect(engines.single, isA<LlmMeterReadingEngine>());
  });

  test('desktop は Unavailable の geminiNano のみ', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    final engines = container.read(meterReadingEnginesProvider);
    expect(engines.map((e) => e.kind).toList(), [
      MeterReadingEngineKind.geminiNano,
    ]);
    expect(engines.single, isA<UnavailableMeterReadingEngine>());
  });
}
