import 'dart:typed_data';

import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_testing/infra_gemma_meter_testing.dart';
import 'package:test/test.dart';

void main() {
  test('ready のとき isAvailable は true', () async {
    final gemma = FakeGemmaMeterVision();
    expect(await gemma.readiness, GemmaMeterReadiness.ready);
    expect(await gemma.isAvailable, isTrue);
  });

  test('modelNotDownloaded のとき isAvailable は false', () async {
    final gemma = FakeGemmaMeterVision(
      readinessValue: GemmaMeterReadiness.modelNotDownloaded,
    );
    expect(await gemma.readiness, GemmaMeterReadiness.modelNotDownloaded);
    expect(await gemma.isAvailable, isFalse);
  });

  test('prepareModel は 1.0 を返す', () async {
    final gemma = FakeGemmaMeterVision();
    expect(await gemma.prepareModel().toList(), [1.0]);
    expect(gemma.prepareModelCallCount, 1);
  });

  test('throwOnAvailabilitySnapshot のとき失敗する', () async {
    final gemma = FakeGemmaMeterVision(throwOnAvailabilitySnapshot: true);
    await expectLater(gemma.availabilitySnapshot, throwsA(isA<StateError>()));
  });

  test('prepareFailureKind のとき型付き例外を投げる', () async {
    final gemma = FakeGemmaMeterVision(
      prepareFailureKind: GemmaMeterPrepareFailureKind.insufficientStorage,
    );
    await expectLater(
      gemma.prepareModel().toList(),
      throwsA(
        isA<GemmaMeterPrepareException>().having(
          (e) => e.kind,
          'kind',
          GemmaMeterPrepareFailureKind.insufficientStorage,
        ),
      ),
    );
    expect(gemma.prepareModelCallCount, 1);
  });

  test('generateWithImage は固定文を返す', () async {
    final gemma = FakeGemmaMeterVision(response: 'DISTANCE_KM=2');
    expect(
      await gemma.generateWithImage(
        prompt: 'panel',
        imageBytes: Uint8List.fromList([1]),
      ),
      'DISTANCE_KM=2',
    );
    expect(gemma.generateWithImageCallCount, 1);
  });
}
