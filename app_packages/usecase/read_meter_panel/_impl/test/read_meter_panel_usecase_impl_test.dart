import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_testing/infra_meter_reading_testing.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_read_meter_panel_impl/usecase_read_meter_panel_impl.dart';

void main() {
  final photo = Uint8List.fromList([1]);

  ReadMeterPanelUsecaseImpl build({
    required OnDeviceLlm llm,
    required MeterReadingEngine llmEngine,
    AppLogStore? log,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return ReadMeterPanelUsecaseImpl(
      llm: llm,
      llmEngine: llmEngine,
      log: log,
      timeout: timeout,
    );
  }

  test('LLM ready+vision なら LLM のみ', () async {
    final log = AppLogStore();
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.ready,
      supportsVisionValue: true,
    );
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(
        distanceKm: 10,
        duration: Duration(hours: 1),
        caloriesKcal: 100,
      ),
    );

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
      log: log,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 1);
    expect(result.values.distanceKm, 10);
    expect(result.values.averageSpeedKmh, 10);
    expect(log.entries.map((e) => e.message), contains(contains('select llm')));
    expect(
      log.entries.map((e) => e.message),
      contains(contains('final present=[distanceKm')),
    );
    expect(
      log.entries.every((e) => !e.message.contains('distanceKm=10')),
      isTrue,
    );
  });

  test('LLM ready で不完全でも空のまま返す', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.ready,
      supportsVisionValue: true,
    );
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      values: const MeterReadingValues(distanceKm: 1),
    );

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 1);
    expect(result.values.distanceKm, 1);
    expect(result.values.duration, isNull);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.incomplete,
    );
  });

  test('modelNotDownloaded ならエンジン無し', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.modelNotDownloaded,
      supportsVisionValue: true,
    );
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 1),
    );

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(result.values.distanceKm, isNull);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.empty,
    );
  });

  test('vision 非対応ならエンジン無し', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.ready,
      supportsVisionValue: false,
    );
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 4),
    );

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(result.values.distanceKm, isNull);
  });

  test('LLM throw でも空を返す', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.ready,
      supportsVisionValue: true,
    );
    final result = await build(
      llm: llm,
      llmEngine: FakeMeterReadingEngine(
        kind: MeterReadingEngineKind.foundationModel,
        throwOnRead: true,
      ),
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(result.values.distanceKm, isNull);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.empty,
    );
  });

  test('LLM unavailable なら read しない', () async {
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      available: false,
    );
    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.ready,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(result.values.distanceKm, isNull);
  });

  test('ハング時は timeout 後に空', () async {
    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.ready,
        supportsVisionValue: true,
      ),
      llmEngine: FakeMeterReadingEngine(
        kind: MeterReadingEngineKind.foundationModel,
        hangOnRead: true,
      ),
      timeout: const Duration(milliseconds: 20),
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(result.values.distanceKm, isNull);
  });
}
