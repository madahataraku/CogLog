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
    expect(result.prepareError, isNull);
    expect(log.entries, isNotEmpty);
  });

  test('未 ready でも生成プローブを試し型名付き例外を残す', () async {
    final usecase = DiagnoseOnDeviceLlmUsecaseImpl(
      llm: FakeOnDeviceLlm(available: false, throwOnGenerate: true),
      log: AppLogStore(),
    );
    final result = await usecase.execute();
    expect(result.canGenerate, isFalse);
    expect(result.probeSkippedReason, isNull);
    expect(result.generateError, contains('StateError'));
    expect(result.generateError, contains('generate failed'));
  });

  test('生成失敗を型名付き generateError に残す', () async {
    final usecase = DiagnoseOnDeviceLlmUsecaseImpl(
      llm: FakeOnDeviceLlm(throwOnGenerate: true),
      log: AppLogStore(),
    );
    final result = await usecase.execute();
    expect(result.canGenerate, isFalse);
    expect(result.generateError, contains('StateError'));
    expect(result.generateError, contains('generate failed'));
  });

  test('prepare 失敗を型名付き prepareError に残す', () async {
    final usecase = DiagnoseOnDeviceLlmUsecaseImpl(
      llm: FakeOnDeviceLlm(response: 'ok', throwOnPrepareModel: true),
      log: AppLogStore(),
    );
    final result = await usecase.execute();
    expect(result.prepareError, contains('StateError'));
    expect(result.prepareError, contains('prepareModel failed'));
    expect(result.canGenerate, isTrue);
    expect(result.generateError, isNull);
    expect(result.sampleOutput, 'ok');
  });

  test('probeGenerate=false なら生成をスキップする', () async {
    final usecase = DiagnoseOnDeviceLlmUsecaseImpl(
      llm: FakeOnDeviceLlm(response: 'ok'),
      log: AppLogStore(),
    );
    final result = await usecase.execute(probeGenerate: false);
    expect(result.canGenerate, isFalse);
    expect(result.probeSkippedReason, 'probeGenerate=false');
    expect(result.generateError, isNull);
  });
}
