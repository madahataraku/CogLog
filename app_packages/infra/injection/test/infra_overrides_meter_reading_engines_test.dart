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

  test('iOS は LLM foundationModel と lfmVl', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);

    expect(
      container.read(meterReadingLlmEngineProvider).kind,
      MeterReadingEngineKind.foundationModel,
    );
    expect(
      container.read(meterReadingLlmEngineProvider),
      isA<LlmMeterReadingEngine>(),
    );
    expect(
      container.read(meterReadingGemmaEngineProvider).kind,
      MeterReadingEngineKind.lfmVl,
    );
    expect(
      container.read(meterReadingGemmaEngineProvider),
      isA<GemmaMeterReadingEngine>(),
    );
    expect(container.read(meterReadingEnginesProvider), hasLength(2));
    expect(container.read(meterReadingEnginesProvider).map((e) => e.kind), [
      MeterReadingEngineKind.foundationModel,
      MeterReadingEngineKind.lfmVl,
    ]);
  });

  test('Android は LLM geminiNano と lfmVl', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);

    expect(
      container.read(meterReadingLlmEngineProvider).kind,
      MeterReadingEngineKind.geminiNano,
    );
    expect(
      container.read(meterReadingGemmaEngineProvider).kind,
      MeterReadingEngineKind.lfmVl,
    );
    expect(container.read(meterReadingEnginesProvider), hasLength(2));
    expect(container.read(meterReadingEnginesProvider).map((e) => e.kind), [
      MeterReadingEngineKind.geminiNano,
      MeterReadingEngineKind.lfmVl,
    ]);
  });

  test('desktop は Unavailable LLM と lfmVl', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);

    expect(
      container.read(meterReadingLlmEngineProvider),
      isA<UnavailableMeterReadingEngine>(),
    );
    expect(
      container.read(meterReadingGemmaEngineProvider).kind,
      MeterReadingEngineKind.lfmVl,
    );
    expect(container.read(meterReadingEnginesProvider), hasLength(2));
    expect(
      container.read(meterReadingEnginesProvider).map((e) => e.kind),
      contains(MeterReadingEngineKind.lfmVl),
    );
  });
}
