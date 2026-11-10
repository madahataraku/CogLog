import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_on_device_llm_guidance_impl/usecase_on_device_llm_guidance_impl.dart';

void main() {
  test('modelNotDownloaded のとき shouldShow true', () async {
    final llm = FakeOnDeviceLlm(
      readiness: OnDeviceLlmReadiness.modelNotDownloaded,
    );
    final result = await EvaluateOnDeviceLlmGuidanceUsecaseImpl(llm: llm)
        .execute();
    expect(result.shouldShow, isTrue);
  });

  test('ready のとき shouldShow false', () async {
    final result = await EvaluateOnDeviceLlmGuidanceUsecaseImpl(
      llm: FakeOnDeviceLlm(),
    ).execute();
    expect(result.shouldShow, isFalse);
  });

  test('unavailable のとき shouldShow false', () async {
    final result = await EvaluateOnDeviceLlmGuidanceUsecaseImpl(
      llm: FakeOnDeviceLlm(available: false),
    ).execute();
    expect(result.shouldShow, isFalse);
  });

  test('readiness 例外のとき shouldShow false', () async {
    final result = await EvaluateOnDeviceLlmGuidanceUsecaseImpl(
      llm: FakeOnDeviceLlm(throwOnReadiness: true),
    ).execute();
    expect(result.shouldShow, isFalse);
  });

  test('prepare は llm.prepareModel を呼ぶ', () async {
    final llm = FakeOnDeviceLlm();
    await PrepareOnDeviceLlmModelUsecaseImpl(llm: llm).execute();
    expect(llm.prepareModelCallCount, 1);
  });
}
