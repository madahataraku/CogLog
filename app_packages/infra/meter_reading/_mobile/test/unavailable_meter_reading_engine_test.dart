import 'dart:typed_data';

import 'package:infra_meter_reading/infra_meter_reading.dart';
import 'package:infra_meter_reading_mobile/infra_meter_reading_mobile.dart';
import 'package:test/test.dart';

void main() {
  test('isAvailable は false', () async {
    const engine = UnavailableMeterReadingEngine(
      MeterReadingEngineKind.foundationModel,
    );
    expect(await engine.isAvailable, isFalse);
    expect(engine.kind, MeterReadingEngineKind.foundationModel);
  });

  test('read は失敗する', () async {
    const engine = UnavailableMeterReadingEngine(
      MeterReadingEngineKind.geminiNano,
    );
    await expectLater(engine.read(Uint8List(0)), throwsStateError);
  });
}
