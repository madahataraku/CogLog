import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:foundation_debug_overrides/foundation_debug_overrides.dart';
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
    required MeterReadingEngine spatialEngine,
    ForceSpatialOcrStore? forceSpatialOcr,
    AppLogStore? log,
    Duration timeout = const Duration(seconds: 30),
  }) {
    return ReadMeterPanelUsecaseImpl(
      llm: llm,
      llmEngine: llmEngine,
      spatialEngine: spatialEngine,
      forceSpatialOcr: forceSpatialOcr ?? ForceSpatialOcrStore(),
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
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      values: const MeterReadingValues(distanceKm: 99),
    );

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
      spatialEngine: spatial,
      log: log,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 1);
    expect(spatial.readCallCount, 0);
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

  test('LLM ready で不完全でも空間 OCR へ落とさない', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.ready,
      supportsVisionValue: true,
    );
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      values: const MeterReadingValues(distanceKm: 1),
    );
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      values: const MeterReadingValues(
        distanceKm: 2,
        duration: Duration(minutes: 10),
        caloriesKcal: 20,
      ),
    );

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
      spatialEngine: spatial,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 1);
    expect(spatial.readCallCount, 0);
    expect(result.values.distanceKm, 1);
    expect(result.values.duration, isNull);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.incomplete,
    );
  });

  test('modelNotDownloaded なら空間 OCR のみ', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.modelNotDownloaded,
      supportsVisionValue: true,
    );
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 1),
    );
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      values: const MeterReadingValues(
        distanceKm: 3,
        duration: Duration(hours: 1),
        caloriesKcal: 30,
      ),
    );

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
      spatialEngine: spatial,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(spatial.readCallCount, 1);
    expect(result.values.distanceKm, 3);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.complete,
    );
  });

  test('vision 非対応なら空間 OCR のみ', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.ready,
      supportsVisionValue: false,
    );
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
    );
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      values: const MeterReadingValues(distanceKm: 4),
    );

    await build(
      llm: llm,
      llmEngine: llmEngine,
      spatialEngine: spatial,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(spatial.readCallCount, 1);
  });

  test('空間 OCR throw でも空を返す', () async {
    final llm = FakeOnDeviceLlm(readiness: OnDeviceLlmReadiness.unavailable);
    final result = await build(
      llm: llm,
      llmEngine: FakeMeterReadingEngine(
        kind: MeterReadingEngineKind.foundationModel,
      ),
      spatialEngine: FakeMeterReadingEngine(
        kind: MeterReadingEngineKind.visionOcr,
        throwOnRead: true,
      ),
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(result.values.distanceKm, isNull);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.empty,
    );
  });

  test('空間 OCR unavailable なら read しない', () async {
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      available: false,
    );
    final result = await build(
      llm: FakeOnDeviceLlm(readiness: OnDeviceLlmReadiness.unavailable),
      llmEngine: FakeMeterReadingEngine(
        kind: MeterReadingEngineKind.foundationModel,
      ),
      spatialEngine: spatial,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(spatial.readCallCount, 0);
    expect(result.values.distanceKm, isNull);
  });

  test('ハング時は timeout 後に空', () async {
    final result = await build(
      llm: FakeOnDeviceLlm(readiness: OnDeviceLlmReadiness.unavailable),
      llmEngine: FakeMeterReadingEngine(
        kind: MeterReadingEngineKind.foundationModel,
      ),
      spatialEngine: FakeMeterReadingEngine(
        kind: MeterReadingEngineKind.visionOcr,
        hangOnRead: true,
      ),
      timeout: const Duration(milliseconds: 20),
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(result.values.distanceKm, isNull);
  });

  test('強制 ON+ready+vision なら空間 OCR のみ', () async {
    final force = ForceSpatialOcrStore()..setEnabled(true);
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 10),
    );
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      values: const MeterReadingValues(
        distanceKm: 5,
        duration: Duration(hours: 1),
        caloriesKcal: 50,
      ),
    );

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.ready,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
      spatialEngine: spatial,
      forceSpatialOcr: force,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(spatial.readCallCount, 1);
    expect(result.values.distanceKm, 5);
  });

  test('強制 ON+spatial unavailable なら空手打ち・LLM 非呼出', () async {
    final force = ForceSpatialOcrStore()..setEnabled(true);
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 10),
    );
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      available: false,
    );

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.ready,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
      spatialEngine: spatial,
      forceSpatialOcr: force,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(spatial.readCallCount, 0);
    expect(result.values.distanceKm, isNull);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.empty,
    );
  });

  test('強制 ON+modelNotDownloaded なら空間 OCR のみ', () async {
    final force = ForceSpatialOcrStore()..setEnabled(true);
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 1),
    );
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      values: const MeterReadingValues(distanceKm: 7),
    );

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.modelNotDownloaded,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
      spatialEngine: spatial,
      forceSpatialOcr: force,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(spatial.readCallCount, 1);
    expect(result.values.distanceKm, 7);
  });

  test('同一 store で ON→OFF 後は LLM に復帰', () async {
    final force = ForceSpatialOcrStore()..setEnabled(true);
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
    final spatial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      values: const MeterReadingValues(distanceKm: 99),
    );
    final usecase = build(
      llm: llm,
      llmEngine: llmEngine,
      spatialEngine: spatial,
      forceSpatialOcr: force,
    );

    await usecase.execute(ReadMeterPanelRequest(photoBytes: photo));
    expect(llmEngine.readCallCount, 0);
    expect(spatial.readCallCount, 1);

    force.setEnabled(false);
    await usecase.execute(ReadMeterPanelRequest(photoBytes: photo));
    expect(llmEngine.readCallCount, 1);
    expect(spatial.readCallCount, 1);
  });
}
