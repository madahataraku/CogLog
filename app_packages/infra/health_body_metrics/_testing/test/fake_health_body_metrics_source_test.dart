import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:infra_health_body_metrics_testing/infra_health_body_metrics_testing.dart';
import 'package:test/test.dart';

void main() {
  test('requestPermission は requestResult を status に書く', () async {
    final source = FakeHealthBodyMetricsSource(
      status: HealthBodyPermissionStatus.denied,
      requestResult: HealthBodyPermissionStatus.granted,
    );

    expect(
      await source.requestPermission(),
      HealthBodyPermissionStatus.granted,
    );
    expect(source.status, HealthBodyPermissionStatus.granted);
    expect(source.requestCallCount, 1);
  });

  test('granted のとき期間内サンプルだけ返す', () async {
    final source = FakeHealthBodyMetricsSource(
      status: HealthBodyPermissionStatus.granted,
      samples: [
        HealthBodySample(
          kind: HealthBodyMetricKind.weightKg,
          at: DateTime(2026, 11, 9, 8),
          value: 70,
        ),
        HealthBodySample(
          kind: HealthBodyMetricKind.weightKg,
          at: DateTime(2026, 11, 12, 8),
          value: 71,
        ),
      ],
    );

    final samples = await source.read(
      startInclusive: DateTime(2026, 11, 9),
      endExclusive: DateTime(2026, 11, 11),
    );

    expect(samples, hasLength(1));
    expect(samples.single.value, 70);
    expect(source.readCallCount, 1);
  });

  test('denied のとき空、throwOnRead で例外', () async {
    final denied = FakeHealthBodyMetricsSource(
      status: HealthBodyPermissionStatus.denied,
      samples: [
        HealthBodySample(
          kind: HealthBodyMetricKind.weightKg,
          at: DateTime(2026, 11, 9, 8),
          value: 70,
        ),
      ],
    );
    expect(
      await denied.read(
        startInclusive: DateTime(2026, 11, 1),
        endExclusive: DateTime(2026, 11, 11),
      ),
      isEmpty,
    );

    final failing = FakeHealthBodyMetricsSource(
      status: HealthBodyPermissionStatus.granted,
      throwOnRead: true,
    );
    await expectLater(
      failing.read(
        startInclusive: DateTime(2026, 11, 1),
        endExclusive: DateTime(2026, 11, 11),
      ),
      throwsA(isA<HealthBodyMetricsReadException>()),
    );
  });
}
