import 'dart:typed_data';

import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:test/test.dart';

void main() {
  test('ready のとき isAvailable は true', () async {
    final meterVl = FakeMeterVlVision();
    expect(await meterVl.readiness, MeterVlReadiness.ready);
    expect(await meterVl.isAvailable, isTrue);
  });

  test('modelNotDownloaded のとき isAvailable は false', () async {
    final meterVl = FakeMeterVlVision(
      readinessValue: MeterVlReadiness.modelNotDownloaded,
    );
    expect(await meterVl.readiness, MeterVlReadiness.modelNotDownloaded);
    expect(await meterVl.isAvailable, isFalse);
  });

  test('prepareModel は 1.0 を返す', () async {
    final meterVl = FakeMeterVlVision();
    expect(await meterVl.prepareModel().toList(), [1.0]);
    expect(meterVl.prepareModelCallCount, 1);
  });

  test('throwOnAvailabilitySnapshot のとき失敗する', () async {
    final meterVl = FakeMeterVlVision(throwOnAvailabilitySnapshot: true);
    await expectLater(meterVl.availabilitySnapshot, throwsA(isA<StateError>()));
  });

  test('prepareFailureKind のとき型付き例外を投げる', () async {
    final meterVl = FakeMeterVlVision(
      prepareFailureKind: MeterVlPrepareFailureKind.insufficientStorage,
    );
    await expectLater(
      meterVl.prepareModel().toList(),
      throwsA(
        isA<MeterVlPrepareException>().having(
          (e) => e.kind,
          'kind',
          MeterVlPrepareFailureKind.insufficientStorage,
        ),
      ),
    );
    expect(meterVl.prepareModelCallCount, 1);
  });

  test('generateWithImage は固定文を返す', () async {
    final meterVl = FakeMeterVlVision(response: 'DISTANCE_KM=2');
    expect(
      await meterVl.generateWithImage(
        prompt: 'panel',
        imageBytes: Uint8List.fromList([1]),
      ),
      'DISTANCE_KM=2',
    );
    expect(meterVl.generateWithImageCallCount, 1);
  });
}
