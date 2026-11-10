import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:infra_health_body_metrics_mobile/infra_health_body_metrics_mobile.dart';
import 'package:test/test.dart';

void main() {
  test('永久拒否と空読取', () async {
    const source = UnavailableHealthBodyMetricsSource();

    expect(
      await source.permissionStatus(),
      HealthBodyPermissionStatus.permanentlyDenied,
    );
    expect(
      await source.requestPermission(),
      HealthBodyPermissionStatus.permanentlyDenied,
    );
    expect(
      await source.read(
        startInclusive: DateTime(2026, 11, 1),
        endExclusive: DateTime(2026, 11, 11),
      ),
      isEmpty,
    );
  });
}
