import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_mobile/infra_meter_vl_mobile.dart';

void main() {
  test('Unavailable は常に unavailable', () async {
    const meterVl = UnavailableMeterVlVision();
    expect(await meterVl.readiness, MeterVlReadiness.unavailable);
    expect(await meterVl.isAvailable, isFalse);
    expect(
      (await meterVl.availabilitySnapshot).readiness,
      MeterVlReadiness.unavailable,
    );
  });

  test('generate / prepare は失敗する', () async {
    const meterVl = UnavailableMeterVlVision();
    await expectLater(
      meterVl.generateWithImage(prompt: 'x', imageBytes: Uint8List(0)),
      throwsStateError,
    );
    await expectLater(meterVl.prepareModel().toList(), throwsStateError);
  });

  test('deleteDownloadedModels は no-op、isOperationBusy は false', () async {
    const meterVl = UnavailableMeterVlVision();
    await meterVl.deleteDownloadedModels();
    expect(await meterVl.isOperationBusy, isFalse);
  });
}
