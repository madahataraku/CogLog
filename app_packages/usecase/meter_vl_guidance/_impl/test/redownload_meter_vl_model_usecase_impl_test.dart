import 'dart:typed_data';

import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:infra_network_connectivity_testing/infra_network_connectivity_testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usecase_meter_vl_guidance_impl/usecase_meter_vl_guidance_impl.dart';

/// delete 成功直後に busy になるテスト用 [MeterVlVision]。
final class _BusyAfterDeleteMeterVlVision implements MeterVlVision {
  _BusyAfterDeleteMeterVlVision() : _delegate = FakeMeterVlVision();

  final FakeMeterVlVision _delegate;

  int get deleteDownloadedModelsCallCount =>
      _delegate.deleteDownloadedModelsCallCount;

  int get prepareModelCallCount => _delegate.prepareModelCallCount;

  @override
  Future<void> deleteDownloadedModels() async {
    await _delegate.deleteDownloadedModels();
    _delegate.operationBusy = true;
  }

  @override
  Future<bool> get isOperationBusy => _delegate.isOperationBusy;

  @override
  Future<MeterVlReadiness> get readiness => _delegate.readiness;

  @override
  Future<bool> get isAvailable => _delegate.isAvailable;

  @override
  Future<MeterVlAvailabilitySnapshot> get availabilitySnapshot =>
      _delegate.availabilitySnapshot;

  @override
  Future<String> generateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) => _delegate.generateWithImage(prompt: prompt, imageBytes: imageBytes);

  @override
  Future<String> diagnoseGenerateWithImage({
    required String prompt,
    required Uint8List imageBytes,
  }) => _delegate.diagnoseGenerateWithImage(
    prompt: prompt,
    imageBytes: imageBytes,
  );

  @override
  Stream<double> prepareModel() => _delegate.prepareModel();
}

void main() {
  group('RedownloadMeterVlModelUsecaseImpl', () {
    test('Wi-Fi・delete 成功', () async {
      final meterVl = FakeMeterVlVision();
      final usecase = RedownloadMeterVlModelUsecaseImpl(
        network: FakeNetworkConnectivity(),
        meterVl: meterVl,
      );

      final progress = await usecase.execute().toList();

      expect(meterVl.deleteDownloadedModelsCallCount, 1);
      expect(meterVl.prepareModelCallCount, 1);
      expect(progress, [1.0]);
    });

    test('非 Wi-Fi', () async {
      final meterVl = FakeMeterVlVision();
      final network = FakeNetworkConnectivity(isWifiValue: false);
      final usecase = RedownloadMeterVlModelUsecaseImpl(
        network: network,
        meterVl: meterVl,
      );

      await expectLater(
        usecase.execute(),
        emitsError(
          isA<MeterVlPrepareException>().having(
            (e) => e.kind,
            'kind',
            MeterVlPrepareFailureKind.wifiRequired,
          ),
        ),
      );
      expect(meterVl.deleteDownloadedModelsCallCount, 0);
      expect(meterVl.prepareModelCallCount, 0);
    });

    test('delete 失敗', () async {
      final meterVl = FakeMeterVlVision(throwOnDelete: true);
      final usecase = RedownloadMeterVlModelUsecaseImpl(
        network: FakeNetworkConnectivity(),
        meterVl: meterVl,
      );

      await expectLater(
        usecase.execute(),
        emitsError(
          isA<MeterVlPrepareException>().having(
            (e) => e.kind,
            'kind',
            MeterVlPrepareFailureKind.generic,
          ),
        ),
      );
      expect(meterVl.prepareModelCallCount, 0);
    });

    test('delete 後に busy', () async {
      final meterVl = _BusyAfterDeleteMeterVlVision();
      final usecase = RedownloadMeterVlModelUsecaseImpl(
        network: FakeNetworkConnectivity(),
        meterVl: meterVl,
      );

      await expectLater(
        usecase.execute(),
        emitsError(
          isA<MeterVlPrepareException>().having(
            (e) => e.kind,
            'kind',
            MeterVlPrepareFailureKind.generic,
          ),
        ),
      );
      expect(meterVl.deleteDownloadedModelsCallCount, 1);
      expect(meterVl.prepareModelCallCount, 0);
    });

    test('prepare insufficientStorage', () async {
      final meterVl = FakeMeterVlVision(
        prepareFailureKind: MeterVlPrepareFailureKind.insufficientStorage,
      );
      final usecase = RedownloadMeterVlModelUsecaseImpl(
        network: FakeNetworkConnectivity(),
        meterVl: meterVl,
      );

      await expectLater(
        usecase.execute(),
        emitsError(
          isA<MeterVlPrepareException>().having(
            (e) => e.kind,
            'kind',
            MeterVlPrepareFailureKind.insufficientStorage,
          ),
        ),
      );
      expect(meterVl.deleteDownloadedModelsCallCount, 1);
    });
  });
}
