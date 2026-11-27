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
      response: '{"distance":5,"time-hour":0,"time-min":30,"time-sec":0,"calories":80}',
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
    expect(llm.lastPrompt, contains('Reply with JSON only'));
    expect(llm.lastPrompt, contains('"distance"'));
    expect(llm.lastPrompt, contains('"time-hour"'));
    expect(llm.lastPrompt, contains('"calories"'));
    expect(values.distanceKm, 5);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
    expect(values.averageSpeedKmh, isNull);
    expect(log.entries, hasLength(2));
    expect(log.entries.first.tag, 'meter.llm');
    expect(log.entries.first.message, contains('rawLength='));
    expect(log.entries.first.message, isNot(contains('"distance":5')));
    expect(log.entries.last.message, contains('present=[distanceKm'));
    expect(log.entries.last.message, isNot(contains('distanceKm=5')));
  });
}
