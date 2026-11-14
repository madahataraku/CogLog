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

  test('iOS は LLM foundationModel のみ', () {
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
    expect(container.read(meterReadingEnginesProvider), hasLength(1));
    expect(
      container.read(meterReadingEnginesProvider).single.kind,
      MeterReadingEngineKind.foundationModel,
    );
  });

  test('Android は LLM geminiNano のみ', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);

    expect(
      container.read(meterReadingLlmEngineProvider).kind,
      MeterReadingEngineKind.geminiNano,
    );
    expect(container.read(meterReadingEnginesProvider), hasLength(1));
  });

  test('desktop は Unavailable', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);

    expect(
      container.read(meterReadingLlmEngineProvider),
      isA<UnavailableMeterReadingEngine>(),
    );
    expect(container.read(meterReadingEnginesProvider), hasLength(1));
  });
}
