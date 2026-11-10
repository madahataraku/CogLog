import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:infra_health_body_metrics_testing/infra_health_body_metrics_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_request_health_body_permission_impl/usecase_request_health_body_permission_impl.dart';

void main() {
  test('source.requestPermission を 1 回呼び結果を返す', () async {
    final source = FakeHealthBodyMetricsSource(
      status: HealthBodyPermissionStatus.denied,
      requestResult: HealthBodyPermissionStatus.granted,
    );

    final status = await RequestHealthBodyPermissionUsecaseImpl(source: source)
        .execute();

    expect(status, HealthBodyPermissionStatus.granted);
    expect(source.requestCallCount, 1);
    expect(source.status, HealthBodyPermissionStatus.granted);
  });
}
