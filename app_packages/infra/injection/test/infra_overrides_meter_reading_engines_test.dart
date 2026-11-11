import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_injection/infra_injection.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const mlKitChannel = MethodChannel('google_mlkit_text_recognizer');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(mlKitChannel, (call) async {
          switch (call.method) {
            case 'vision#closeTextRecognizer':
            case 'vision#startTextRecognizer':
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(mlKitChannel, null);
  });

  test('iOS は visionOcr → foundationModel', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    final engines = container.read(meterReadingEnginesProvider);
    expect(engines.map((e) => e.kind).toList(), [
      MeterReadingEngineKind.visionOcr,
      MeterReadingEngineKind.foundationModel,
    ]);
    expect(engines[0], isA<OcrMeterReadingEngine>());
    expect(engines[1], isA<LlmMeterReadingEngine>());
  });

  test('Android は mlKit → geminiNano', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    final engines = container.read(meterReadingEnginesProvider);
    expect(engines.map((e) => e.kind).toList(), [
      MeterReadingEngineKind.mlKit,
      MeterReadingEngineKind.geminiNano,
    ]);
    expect(engines[0], isA<OcrMeterReadingEngine>());
    expect(engines[1], isA<LlmMeterReadingEngine>());
  });

  test('desktop は Unavailable の mlKit → geminiNano', () {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    final container = ProviderContainer(overrides: infraOverrides());
    addTearDown(container.dispose);
    final engines = container.read(meterReadingEnginesProvider);
    expect(engines.map((e) => e.kind).toList(), [
      MeterReadingEngineKind.mlKit,
      MeterReadingEngineKind.geminiNano,
    ]);
    expect(engines[0], isA<UnavailableMeterReadingEngine>());
    expect(engines[1], isA<UnavailableMeterReadingEngine>());
  });
}
