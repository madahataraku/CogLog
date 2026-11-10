import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_on_device_llm/infra_on_device_llm.dart';
import 'package:infra_on_device_llm_testing/infra_on_device_llm_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_diagnose_on_device_llm_impl/usecase_diagnose_on_device_llm_impl.dart';

void main() {
  test('ready なら生成プローブ成功を返す', () async {
    final log = AppLogStore();
    final usecase = DiagnoseOnDeviceLlmUsecaseImpl(
      llm: FakeOnDeviceLlm(response: 'ok'),
      log: log,
    );
    final result = await usecase.execute();
    expect(result.canGenerate, isTrue);
    expect(result.sampleOutput, 'ok');
    expect(result.snapshot.readiness, OnDeviceLlmReadiness.ready);
    expect(log.entries, isNotEmpty);
  });

  test('未 ready なら生成をスキップする', () async {
    final usecase = DiagnoseOnDeviceLlmUsecaseImpl(
      llm: FakeOnDeviceLlm(available: false),
      log: AppLogStore(),
    );
    final result = await usecase.execute();
    expect(result.canGenerate, isFalse);
    expect(result.probeSkippedReason, contains('unavailable'));
    expect(result.generateError, isNull);
  });

  test('生成失敗を generateError に残す', () async {
    final usecase = DiagnoseOnDeviceLlmUsecaseImpl(
      llm: FakeOnDeviceLlm(throwOnGenerate: true),
      log: AppLogStore(),
    );
    final result = await usecase.execute();
    expect(result.canGenerate, isFalse);
    expect(result.generateError, contains('generate failed'));
  });
}
