import 'dart:typed_data';

import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:test/test.dart';

void main() {
  test('利用可かつ vision 対応のとき isAvailable', () async {
    final engine = LlmMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      llm: FakeOnDeviceLlm(supportsVisionValue: true),
    );
    expect(await engine.isAvailable, isTrue);
  });

  test('vision 非対応なら isAvailable は false', () async {
    final engine = LlmMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      llm: FakeOnDeviceLlm(supportsVisionValue: false),
    );
    expect(await engine.isAvailable, isFalse);
  });

  test('LLM 自体が不可なら isAvailable は false', () async {
    final engine = LlmMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      llm: FakeOnDeviceLlm(available: false, supportsVisionValue: true),
    );
    expect(await engine.isAvailable, isFalse);
  });

  test('read は固定プロンプトで generateWithImage しパースする', () async {
    final log = AppLogStore();
    final llm = FakeOnDeviceLlm(
      response: 'DISTANCE_KM=5\nDURATION=0:30:00\nCALORIES_KCAL=80',
      supportsVisionValue: true,
    );
    final engine = LlmMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      llm: llm,
      log: log,
    );
    final bytes = Uint8List.fromList([7, 8, 9]);
    final values = await engine.read(bytes);
    expect(llm.generateWithImageCallCount, 1);
    expect(llm.lastImageBytes, bytes);
    expect(
      llm.lastPrompt,
      'You extract stationary bike meter panel values from the image.\n'
      'Reply with ONLY these lines (omit unknown):\n'
      'DISTANCE_KM=<number>\n'
      'DURATION=H:MM:SS\n'
      'CALORIES_KCAL=<number>\n'
      'AVERAGE_SPEED_KMH=<number>\n'
      'Use ASCII digits. No other text.',
    );
    expect(values.distanceKm, 5);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
    expect(values.averageSpeedKmh, isNull);
    expect(log.entries, hasLength(2));
    expect(log.entries.first.tag, 'meter.llm');
    expect(log.entries.first.message, contains('DISTANCE_KM=5'));
    expect(log.entries.last.message, contains('distanceKm=5'));
  });
}
