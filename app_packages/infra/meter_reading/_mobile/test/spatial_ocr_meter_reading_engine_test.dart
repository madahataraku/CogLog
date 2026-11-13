import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:infra_meter_reading_testing/infra_meter_reading_testing.dart';
import 'package:test/test.dart';

void main() {
  test('空間 OCR エンジンは認識結果を推論する', () async {
    final log = AppLogStore();
    final recognizer = FakeMeterLayoutRecognizer(
      tokens: const [
        MeterOcrToken(
          text: '12.3km',
          left: 0.2,
          top: 0.2,
          width: 0.2,
          height: 0.05,
        ),
      ],
    );
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.visionOcr,
      recognizer: recognizer,
      log: log,
    );

    final values = await engine.read(Uint8List(0));
    expect(recognizer.callCount, 1);
    expect(values.distanceKm, 12.3);
    expect(log.entries, hasLength(2));
    expect(log.entries.first.tag, 'meter.spatial');
    expect(log.entries.first.message, contains('tokens=1'));
    expect(log.entries.first.message, contains('12.3km'));
    expect(log.entries.last.message, contains('distanceKm=12.3'));
  });

  test('トークン0件なら warn と空の推論をログする', () async {
    final log = AppLogStore();
    final engine = SpatialOcrMeterReadingEngine(
      kind: MeterReadingEngineKind.mlKit,
      recognizer: FakeMeterLayoutRecognizer(tokens: const []),
      log: log,
    );

    final values = await engine.read(Uint8List(0));
    expect(values.distanceKm, isNull);
    expect(log.entries.first.level, AppLogLevel.warn);
    expect(log.entries.first.message, contains('tokens=0'));
  });
}
