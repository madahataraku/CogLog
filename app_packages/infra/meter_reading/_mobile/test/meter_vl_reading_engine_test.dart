import 'dart:typed_data';

import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:test/test.dart';

void main() {
  test('Fake 応答をパースする', () async {
    final log = AppLogStore();
    final meterVl = FakeMeterVlVision(
      response: '{"distance":5,"time-hour":0,"time-min":30,"time-sec":0,"calories":80}',
    );
    final engine = MeterVlReadingEngine(meterVl: meterVl, log: log);
    expect(engine.kind, MeterReadingEngineKind.lfmVl);
    expect(await engine.isAvailable, isTrue);

    final bytes = Uint8List.fromList([7, 8, 9]);
    final values = await engine.read(bytes);
    expect(meterVl.generateWithImageCallCount, 1);
    expect(values.distanceKm, 5);
    expect(values.duration, const Duration(minutes: 30));
    expect(values.caloriesKcal, 80);
    expect(values.averageSpeedKmh, isNull);
    expect(log.entries, hasLength(2));
    expect(log.entries.first.tag, 'meter.lfm');
    expect(log.entries.first.message, contains('rawLength='));
    expect(log.entries.first.message, isNot(contains('"distance":5')));
    expect(log.entries.last.message, contains('present=[distanceKm'));
    expect(log.entries.last.message, isNot(contains('distanceKm=5')));
  });

  test('unavailable なら isAvailable は false', () async {
    final engine = MeterVlReadingEngine(
      meterVl: FakeMeterVlVision(readinessValue: MeterVlReadiness.unavailable),
    );
    expect(await engine.isAvailable, isFalse);
  });
}
