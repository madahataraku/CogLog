import 'dart:typed_data';

import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:infra_meter_reading_testing/infra_meter_reading_testing.dart';
import 'package:test/test.dart';

void main() {
  test('空間 OCR エンジンは認識結果を推論する', () async {
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
    );

    final values = await engine.read(Uint8List(0));
    expect(recognizer.callCount, 1);
    expect(values.distanceKm, 12.3);
  });
}
