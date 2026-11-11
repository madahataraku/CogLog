import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_testing/infra_meter_reading_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_read_meter_panel/usecase_read_meter_panel.dart';
import 'package:usecase_read_meter_panel_impl/usecase_read_meter_panel_impl.dart';

void main() {
  final photo = Uint8List.fromList([1]);

  // R1: 先のエンジンでコア完了なら打ち切り、後続は呼ばない。
  test('R1: 先のエンジンでコア完了なら後続を呼ばない', () async {
    final first = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      values: const MeterReadingValues(
        distanceKm: 10,
        duration: Duration(hours: 1),
        caloriesKcal: 100,
        averageSpeedKmh: 10,
      ),
    );
    final second = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(distanceKm: 99),
    );

    final result = await ReadMeterPanelUsecaseImpl(engines: [first, second])
        .execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(first.readCallCount, 1);
    expect(second.readCallCount, 0);
    expect(result.values.distanceKm, 10);
    expect(result.values.caloriesKcal, 100);
    expect(result.averageSpeedFromPanel, isTrue);
  });

  // R2: 同項目は後勝ち。
  test('R2: 部分結果の同項目は後勝ち', () async {
    final first = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      values: const MeterReadingValues(
        distanceKm: 1,
        duration: Duration(minutes: 30),
      ),
    );
    final second = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      values: const MeterReadingValues(distanceKm: 2, caloriesKcal: 50),
    );

    final result = await ReadMeterPanelUsecaseImpl(engines: [first, second])
        .execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(first.readCallCount, 1);
    expect(second.readCallCount, 1);
    expect(result.values.distanceKm, 2);
    expect(result.values.duration, const Duration(minutes: 30));
    expect(result.values.caloriesKcal, 50);
    expect(result.averageSpeedFromPanel, isFalse);
    expect(result.values.averageSpeedKmh, 4);
  });

  // R3: 全 unavailable でも例外なし、空に近い values。
  test('R3: 全 unavailable でも空に近い結果を返す', () async {
    final first = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      available: false,
    );
    final second = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      available: false,
    );

    final result = await ReadMeterPanelUsecaseImpl(engines: [first, second])
        .execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(first.readCallCount, 0);
    expect(second.readCallCount, 0);
    expect(result.values.distanceKm, isNull);
    expect(result.values.duration, isNull);
    expect(result.values.caloriesKcal, isNull);
    expect(result.values.averageSpeedKmh, isNull);
    expect(result.averageSpeedFromPanel, isFalse);
  });

  test('利用不可は skip し、利用可能だけ読む', () async {
    final unavailable = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      available: false,
      values: const MeterReadingValues(distanceKm: 1),
    );
    final available = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      values: const MeterReadingValues(
        distanceKm: 3,
        duration: Duration(hours: 1),
        caloriesKcal: 30,
      ),
    );

    final result = await ReadMeterPanelUsecaseImpl(
      engines: [unavailable, available],
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(unavailable.readCallCount, 0);
    expect(available.readCallCount, 1);
    expect(result.values.distanceKm, 3);
    expect(result.averageSpeedFromPanel, isFalse);
    expect(result.values.averageSpeedKmh, 3);
  });

  test('read 失敗は次エンジンへ進む', () async {
    final failing = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      throwOnRead: true,
    );
    final ok = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.foundationModel,
      values: const MeterReadingValues(
        distanceKm: 5,
        duration: Duration(hours: 1),
        caloriesKcal: 40,
        averageSpeedKmh: 5,
      ),
    );

    final result = await ReadMeterPanelUsecaseImpl(engines: [failing, ok])
        .execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(failing.readCallCount, 1);
    expect(ok.readCallCount, 1);
    expect(result.values.distanceKm, 5);
    expect(result.averageSpeedFromPanel, isTrue);
  });

  test('タイムアウト: 先頭 hang なら空に近い結果', () async {
    final hang = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      hangOnRead: true,
    );
    final result = await ReadMeterPanelUsecaseImpl(
      engines: [hang],
      timeout: const Duration(milliseconds: 20),
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(result.values.distanceKm, isNull);
    expect(result.values.averageSpeedKmh, isNull);
    expect(result.averageSpeedFromPanel, isFalse);
  });

  test('タイムアウト: 部分マージ後 hang なら部分結果', () async {
    final partial = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      values: const MeterReadingValues(distanceKm: 7, averageSpeedKmh: 11),
    );
    final hang = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      hangOnRead: true,
    );
    final result = await ReadMeterPanelUsecaseImpl(
      engines: [partial, hang],
      timeout: const Duration(milliseconds: 20),
    ).execute(ReadMeterPanelRequest(photoBytes: photo));

    expect(result.values.distanceKm, 7);
    expect(result.values.averageSpeedKmh, 11);
    expect(result.averageSpeedFromPanel, isTrue);
  });
}
