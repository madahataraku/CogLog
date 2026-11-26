import 'package:infra_meter_vl/infra_meter_vl.dart';
import 'package:infra_meter_vl_testing/infra_meter_vl_testing.dart';
import 'package:infra_network_connectivity_testing/infra_network_connectivity_testing.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usecase_meter_vl_guidance_impl/usecase_meter_vl_guidance_impl.dart';

void main() {
  group('EvaluateMeterVlGuidanceUsecaseImpl', () {
    test('unavailable かつメーター VL 未DL のとき shouldShow true', () async {
      final result = await EvaluateMeterVlGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(available: false),
        meterVl: FakeMeterVlVision(
          readinessValue: MeterVlReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isTrue);
    });

    test('ready だが vision 非対応かつメーター VL 未DL のとき shouldShow true', () async {
      final result = await EvaluateMeterVlGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(supportsVisionValue: false),
        meterVl: FakeMeterVlVision(
          readinessValue: MeterVlReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isTrue);
    });

    test('(A) 成立時（modelNotDownloaded）は shouldShow false', () async {
      final result = await EvaluateMeterVlGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(
          readiness: OnDeviceLlmReadiness.modelNotDownloaded,
          supportsVisionValue: true,
        ),
        meterVl: FakeMeterVlVision(
          readinessValue: MeterVlReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isFalse);
    });

    test('ready+vision のとき shouldShow false', () async {
      final result = await EvaluateMeterVlGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(supportsVisionValue: true),
        meterVl: FakeMeterVlVision(
          readinessValue: MeterVlReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isFalse);
    });

    test('メーター VL ready のとき shouldShow false', () async {
      final result = await EvaluateMeterVlGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(available: false),
        meterVl: FakeMeterVlVision(),
      ).execute();
      expect(result.shouldShow, isFalse);
    });

    test('メーター VL unavailable のとき shouldShow false', () async {
      final result = await EvaluateMeterVlGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(available: false),
        meterVl: FakeMeterVlVision(
          readinessValue: MeterVlReadiness.unavailable,
        ),
      ).execute();
      expect(result.shouldShow, isFalse);
    });

    test('readiness 例外のとき shouldShow false', () async {
      final result = await EvaluateMeterVlGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(throwOnReadiness: true),
        meterVl: FakeMeterVlVision(
          readinessValue: MeterVlReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isFalse);
    });
  });

  group('PrepareMeterVlModelUsecaseImpl', () {
    test('Wi-Fi なら prepareModel の進捗を流す', () async {
      final meterVl = FakeMeterVlVision();
      final network = FakeNetworkConnectivity();
      final progress = await PrepareMeterVlModelUsecaseImpl(
        network: network,
        meterVl: meterVl,
      ).execute().toList();
      expect(progress, [1.0]);
      expect(network.isWifiCallCount, 1);
      expect(meterVl.prepareModelCallCount, 1);
    });

    test('非 Wi-Fi なら wifiRequired で失敗し prepare しない', () async {
      final meterVl = FakeMeterVlVision();
      await expectLater(
        PrepareMeterVlModelUsecaseImpl(
          network: FakeNetworkConnectivity(isWifiValue: false),
          meterVl: meterVl,
        ).execute().toList(),
        throwsA(
          isA<MeterVlPrepareException>().having(
            (e) => e.kind,
            'kind',
            MeterVlPrepareFailureKind.wifiRequired,
          ),
        ),
      );
      expect(meterVl.prepareModelCallCount, 0);
    });
  });
}
