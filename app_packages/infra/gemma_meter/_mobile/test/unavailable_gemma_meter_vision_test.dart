import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_mobile/infra_gemma_meter_mobile.dart';

void main() {
  test('Unavailable は常に unavailable', () async {
    const gemma = UnavailableGemmaMeterVision();
    expect(await gemma.readiness, GemmaMeterReadiness.unavailable);
    expect(await gemma.isAvailable, isFalse);
    expect(
      (await gemma.availabilitySnapshot).readiness,
      GemmaMeterReadiness.unavailable,
    );
  });

  test('generate / prepare は失敗する', () async {
    const gemma = UnavailableGemmaMeterVision();
    await expectLater(
      gemma.generateWithImage(prompt: 'x', imageBytes: Uint8List(0)),
      throwsStateError,
    );
    await expectLater(gemma.prepareModel().toList(), throwsStateError);
  });
}
