import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_testing/infra_meter_reading_testing.dart';
import 'package:test/test.dart';

void main() {
  test('利用可のとき固定値を返す', () async {
    final engine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      values: const MeterReadingValues(distanceKm: 2.5),
    );

    expect(await engine.isAvailable, isTrue);
    final values = await engine.read(Uint8List.fromList([9]));
    expect(values.distanceKm, 2.5);
    expect(engine.readCallCount, 1);
    expect(engine.lastPhotoBytes, Uint8List.fromList([9]));
  });

  test('available false を返す', () async {
    final engine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      available: false,
    );
    expect(await engine.isAvailable, isFalse);
  });

  test('throwOnRead で失敗する', () async {
    final engine = FakeMeterReadingEngine(
      kind: MeterReadingEngineKind.geminiNano,
      throwOnRead: true,
    );
    await expectLater(engine.read(Uint8List(0)), throwsStateError);
  });
}
