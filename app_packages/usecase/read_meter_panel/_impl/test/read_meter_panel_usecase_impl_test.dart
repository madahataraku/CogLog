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

  FakeMeterReadingEngine unavailableGemma() => FakeMeterReadingEngine(
    kind: MeterReadingEngineKind.gemmaE2b,
    available: false,
  );

  ReadMeterPanelUsecaseImpl build({
    required OnDeviceLlm llm,
    required MeterReadingEngine llmEngine,
    required MeterReadingEngine gemmaEngine,
    AppLogStore? log,
    MeterReadingEngineSessionPreference? sessionPreference,
    Duration timeout = const Duration(seconds: 60),
  }) {
    return ReadMeterPanelUsecaseImpl(
      llm: llm,
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
      log: log,
      sessionPreference: sessionPreference,
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
    final gemmaEngine = unavailableGemma();

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
      log: log,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 1);
    expect(gemmaEngine.readCallCount, 0);
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
      gemmaEngine: unavailableGemma(),
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
    final gemmaEngine = unavailableGemma();

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(gemmaEngine.readCallCount, 0);
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
    final gemmaEngine = unavailableGemma();

    final result = await build(
      llm: llm,
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(gemmaEngine.readCallCount, 0);
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
      gemmaEngine: unavailableGemma(),
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
      gemmaEngine: unavailableGemma(),
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
      gemmaEngine: unavailableGemma(),
      timeout: const Duration(milliseconds: 20),
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(result.values.distanceKm, isNull);
  });

  test('OS ready+vision なら Gemma を呼ばない', () async {
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(
        distanceKm: 5,
        duration: Duration(minutes: 30),
        caloriesKcal: 50,
      ),
    );
    final gemmaEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.gemmaE2b,
      values: const MeterReadingValues(distanceKm: 99),
    );

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.ready,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 1);
    expect(gemmaEngine.readCallCount, 0);
    expect(result.values.distanceKm, 5);
  });

  test('preferGemma かつ Gemma available なら OS ready+vision でも Gemma', () async {
    final log = AppLogStore();
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 5),
    );
    final gemmaEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.gemmaE2b,
      values: const MeterReadingValues(
        distanceKm: 8,
        duration: Duration(minutes: 25),
        caloriesKcal: 40,
      ),
    );

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.ready,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
      sessionPreference: MeterReadingEngineSessionPreference()
        ..preferGemmaOverOsLlm = true,
      log: log,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(gemmaEngine.readCallCount, 1);
    expect(result.values.distanceKm, 8);
    expect(
      log.entries.map((e) => e.message),
      contains(contains('reason=debug_prefer_gemma')),
    );
  });

  test('preferGemma でも Gemma unavailable なら OS LLM', () async {
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(
        distanceKm: 5,
        duration: Duration(minutes: 30),
        caloriesKcal: 50,
      ),
    );
    final gemmaEngine = unavailableGemma();

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.ready,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
      sessionPreference: MeterReadingEngineSessionPreference()
        ..preferGemmaOverOsLlm = true,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 1);
    expect(gemmaEngine.readCallCount, 0);
    expect(result.values.distanceKm, 5);
  });

  test('OS modelNotDownloaded + Gemma ready なら Gemma のみ', () async {
    final log = AppLogStore();
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 1),
    );
    final gemmaEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.gemmaE2b,
      values: const MeterReadingValues(
        distanceKm: 3,
        duration: Duration(minutes: 20),
        caloriesKcal: 30,
      ),
    );

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.modelNotDownloaded,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
      log: log,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(gemmaEngine.readCallCount, 1);
    expect(result.values.distanceKm, 3);
    expect(
      log.entries.map((e) => e.message),
      contains(contains('select gemma')),
    );
  });

  test('OS vision 非対応 + Gemma ready なら Gemma のみ', () async {
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 1),
    );
    final gemmaEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.gemmaE2b,
      values: const MeterReadingValues(
        distanceKm: 7,
        duration: Duration(minutes: 40),
        caloriesKcal: 70,
      ),
    );

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.ready,
        supportsVisionValue: false,
      ),
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(gemmaEngine.readCallCount, 1);
    expect(result.values.distanceKm, 7);
  });

  test('両方 unavailable なら空', () async {
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 1),
    );
    final gemmaEngine = unavailableGemma();

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.unavailable,
        supportsVisionValue: false,
      ),
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(gemmaEngine.readCallCount, 0);
    expect(result.values.distanceKm, isNull);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.empty,
    );
  });

  test('Gemma throwOnRead でも空・クラッシュなし', () async {
    final llmEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 1),
    );
    final gemmaEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.gemmaE2b,
      throwOnRead: true,
    );

    final result = await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.modelNotDownloaded,
        supportsVisionValue: true,
      ),
      llmEngine: llmEngine,
      gemmaEngine: gemmaEngine,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(llmEngine.readCallCount, 0);
    expect(gemmaEngine.readCallCount, 1);
    expect(result.values.distanceKm, isNull);
    expect(
      classifyMeterReadingMessages(result.values),
      MeterReadingMessageKind.empty,
    );
  });

  test('AppLog に測定値・生文が無い', () async {
    final log = AppLogStore();
    final gemmaEngine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.gemmaE2b,
      values: const MeterReadingValues(
        distanceKm: 12.5,
        duration: Duration(minutes: 15),
        caloriesKcal: 88,
      ),
    );

    await build(
      llm: FakeOnDeviceLlm(
        readiness: OnDeviceLlmReadiness.modelNotDownloaded,
        supportsVisionValue: true,
      ),
      llmEngine: FakeMeterReadingEngine(
        kind: MeterReadingEngineKind.foundationModel,
      ),
      gemmaEngine: gemmaEngine,
      log: log,
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(gemmaEngine.readCallCount, 1);
    for (final entry in log.entries) {
      expect(entry.message.contains('12.5'), isFalse);
      expect(entry.message.contains('DISTANCE_KM'), isFalse);
      expect(entry.message.contains('distanceKm=12'), isFalse);
      expect(entry.message.contains('caloriesKcal=88'), isFalse);
    }
  });
}
