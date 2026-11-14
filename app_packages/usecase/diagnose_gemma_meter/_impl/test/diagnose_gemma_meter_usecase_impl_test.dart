import 'package:foundation_app_log/foundation_app_log.dart';
import 'package:infra_gemma_meter/infra_gemma_meter.dart';
import 'package:infra_gemma_meter_testing/infra_gemma_meter_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_diagnose_gemma_meter_impl/usecase_diagnose_gemma_meter_impl.dart';

void main() {
  test('ready なら画像プローブ成功を長さだけ返す', () async {
    const body = 'SECRET_PROBE_BODY';
    final log = AppLogStore();
    final usecase = DiagnoseGemmaMeterUsecaseImpl(
      gemma: FakeGemmaMeterVision(response: body),
      log: log,
    );
    final result = await usecase.execute();
    expect(result.canGenerate, isTrue);
    expect(result.probeOutputLength, body.length);
    expect(result.snapshot.readiness, GemmaMeterReadiness.ready);
    expect(result.prepareError, isNull);
    expect(result.availabilityError, isNull);
    expect(log.entries.map((e) => e.message).join('\n'), isNot(contains(body)));
    expect(log.entries, isNotEmpty);
  });

  test('生成プローブ失敗を型名付き例外として残す', () async {
    final usecase = DiagnoseGemmaMeterUsecaseImpl(
      gemma: FakeGemmaMeterVision(throwOnGenerate: true),
      log: AppLogStore(),
    );
    final result = await usecase.execute();
    expect(result.canGenerate, isFalse);
    expect(result.probeSkippedReason, isNull);
    expect(result.probeOutputLength, isNull);
    expect(result.generateError, contains('StateError'));
    expect(result.generateError, contains('generate failed'));
  });

  test('prepare 失敗を型名付き prepareError に残す', () async {
    final usecase = DiagnoseGemmaMeterUsecaseImpl(
      gemma: FakeGemmaMeterVision(response: 'ok', throwOnPrepare: true),
      log: AppLogStore(),
    );
    final result = await usecase.execute();
    expect(result.prepareError, contains('StateError'));
    expect(result.prepareError, contains('prepare failed'));
    expect(result.canGenerate, isTrue);
    expect(result.generateError, isNull);
    expect(result.probeOutputLength, 2);
  });

  test('availability 失敗を型名付き availabilityError に残す', () async {
    final usecase = DiagnoseGemmaMeterUsecaseImpl(
      gemma: FakeGemmaMeterVision(throwOnAvailabilitySnapshot: true),
      log: AppLogStore(),
    );
    final result = await usecase.execute();
    expect(result.availabilityError, contains('StateError'));
    expect(result.snapshot.readiness, GemmaMeterReadiness.unavailable);
    expect(result.snapshot.status, 'error');
  });

  test('probeGenerate=false なら生成をスキップする', () async {
    final usecase = DiagnoseGemmaMeterUsecaseImpl(
      gemma: FakeGemmaMeterVision(response: 'ok'),
      log: AppLogStore(),
    );
    final result = await usecase.execute(probeGenerate: false);
    expect(result.canGenerate, isFalse);
    expect(result.probeSkippedReason, 'probeGenerate=false');
    expect(result.generateError, isNull);
    expect(result.probeOutputLength, isNull);
  });
}
