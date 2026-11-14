import 'dart:typed_data';

import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_testing/infra_gemma_meter_testing.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:test/test.dart';

void main() {
  test('Fake 応答をパースする', () async {
    final log = AppLogStore();
    final gemma = FakeGemmaMeterVision(
      response: 'DISTANCE_KM=5\nDURATION=0:30:00\nCALORIES_KCAL=80',
    );
    final engine = GemmaMeterReadingEngine(gemma: gemma, log: log);
    expect(engine.kind, MeterReadingEngineKind.gemmaE2b);
    expect(await engine.isAvailable, isTrue);

    final bytes = Uint8List.fromList([7, 8, 9]);
    final values = await engine.read(bytes);
    expect(gemma.generateWithImageCallCount, 1);
    expect(values.distanceKm, 5);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
    expect(values.averageSpeedKmh, isNull);
    expect(log.entries, hasLength(2));
    expect(log.entries.first.tag, 'meter.gemma');
    expect(log.entries.first.message, contains('rawLength='));
    expect(log.entries.first.message, isNot(contains('DISTANCE_KM=')));
    expect(log.entries.last.message, contains('present=[distanceKm'));
    expect(log.entries.last.message, isNot(contains('distanceKm=5')));
  });

  test('unavailable なら isAvailable は false', () async {
    final engine = GemmaMeterReadingEngine(
      gemma: FakeGemmaMeterVision(
        readinessValue: GemmaMeterReadiness.unavailable,
      ),
    );
    expect(await engine.isAvailable, isFalse);
  });
}
