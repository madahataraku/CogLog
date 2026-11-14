import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_testing/infra_gemma_meter_testing.dart';
import 'package:infra_network_connectivity_testing/infra_network_connectivity_testing.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_gemma_meter_guidance_impl/usecase_gemma_meter_guidance_impl.dart';

void main() {
  group('EvaluateGemmaMeterGuidanceUsecaseImpl', () {
    test('unavailable かつ Gemma 未DL のとき shouldShow true', () async {
      final result = await EvaluateGemmaMeterGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(available: false),
        gemma: FakeGemmaMeterVision(
          readinessValue: GemmaMeterReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isTrue);
    });

    test('ready だが vision 非対応かつ Gemma 未DL のとき shouldShow true', () async {
      final result = await EvaluateGemmaMeterGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(supportsVisionValue: false),
        gemma: FakeGemmaMeterVision(
          readinessValue: GemmaMeterReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isTrue);
    });

    test('(A) 成立時（modelNotDownloaded）は shouldShow false', () async {
      final result = await EvaluateGemmaMeterGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(
          readiness: OnDeviceLlmReadiness.modelNotDownloaded,
          supportsVisionValue: true,
        ),
        gemma: FakeGemmaMeterVision(
          readinessValue: GemmaMeterReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isFalse);
    });

    test('ready+vision のとき shouldShow false', () async {
      final result = await EvaluateGemmaMeterGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(supportsVisionValue: true),
        gemma: FakeGemmaMeterVision(
          readinessValue: GemmaMeterReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isFalse);
    });

    test('Gemma ready のとき shouldShow false', () async {
      final result = await EvaluateGemmaMeterGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(available: false),
        gemma: FakeGemmaMeterVision(),
      ).execute();
      expect(result.shouldShow, isFalse);
    });

    test('Gemma unavailable のとき shouldShow false', () async {
      final result = await EvaluateGemmaMeterGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(available: false),
        gemma: FakeGemmaMeterVision(
          readinessValue: GemmaMeterReadiness.unavailable,
        ),
      ).execute();
      expect(result.shouldShow, isFalse);
    });

    test('readiness 例外のとき shouldShow false', () async {
      final result = await EvaluateGemmaMeterGuidanceUsecaseImpl(
        llm: FakeOnDeviceLlm(throwOnReadiness: true),
        gemma: FakeGemmaMeterVision(
          readinessValue: GemmaMeterReadiness.modelNotDownloaded,
        ),
      ).execute();
      expect(result.shouldShow, isFalse);
    });
  });

  group('PrepareGemmaMeterModelUsecaseImpl', () {
    test('Wi-Fi なら prepareModel の進捗を流す', () async {
      final gemma = FakeGemmaMeterVision();
      final network = FakeNetworkConnectivity();
      final progress = await PrepareGemmaMeterModelUsecaseImpl(
        network: network,
        gemma: gemma,
      ).execute().toList();
      expect(progress, [1.0]);
      expect(network.isWifiCallCount, 1);
      expect(gemma.prepareModelCallCount, 1);
    });

    test('非 Wi-Fi なら wifiRequired で失敗し prepare しない', () async {
      final gemma = FakeGemmaMeterVision();
      await expectLater(
        PrepareGemmaMeterModelUsecaseImpl(
          network: FakeNetworkConnectivity(isWifiValue: false),
          gemma: gemma,
        ).execute().toList(),
        throwsA(
          isA<GemmaMeterPrepareException>().having(
            (e) => e.kind,
            'kind',
            GemmaMeterPrepareFailureKind.wifiRequired,
          ),
        ),
      );
      expect(gemma.prepareModelCallCount, 0);
    });
  });
}
