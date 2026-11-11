import 'dart:typed_data';

import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_mobile/infra_on_device_llm_mobile.dart';
import 'package:test/test.dart';

void main() {
  test('readiness は unavailable', () async {
    expect(
      await const UnavailableOnDeviceLlm().readiness,
      OnDeviceLlmReadiness.unavailable,
    );
  });

  test('isAvailable は false', () async {
    expect(await const UnavailableOnDeviceLlm().isAvailable, isFalse);
  });

  test('supportsVision は false', () async {
    expect(await const UnavailableOnDeviceLlm().supportsVision, isFalse);
  });

  test('availabilitySnapshot は unavailable', () async {
    final snapshot = await const UnavailableOnDeviceLlm().availabilitySnapshot;
    expect(snapshot.readiness, OnDeviceLlmReadiness.unavailable);
    expect(snapshot.status, 'unavailable');
  });

  test('generate は失敗する', () async {
    await expectLater(
      const UnavailableOnDeviceLlm().generate('prompt'),
      throwsStateError,
    );
  });

  test('generateWithImage は失敗する', () async {
    await expectLater(
      const UnavailableOnDeviceLlm().generateWithImage(
        prompt: 'prompt',
        imageBytes: Uint8List(0),
      ),
      throwsStateError,
    );
  });

  test('prepareModel は何もしない', () async {
    await const UnavailableOnDeviceLlm().prepareModel();
  });
}
