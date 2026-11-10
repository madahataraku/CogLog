import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:domain_trends/domain_trends.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:infra_health_body_metrics_testing/infra_health_body_metrics_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';
import 'package:usecase_load_trends_impl/usecase_load_trends_impl.dart';

ExerciseHistory ride({
  required DateTime recordedAt,
  double caloriesKcal = 100,
  String id = '11111111-1111-4111-8111-111111111111',
}) {
  return ExerciseHistory(
    id: id,
    savedAt: recordedAt,
    creationStartedAt: recordedAt,
    capturedAt: recordedAt,
    recordedAt: recordedAt,
    recordedAtManuallySet: false,
    distanceKm: 1,
    duration: const Duration(minutes: 30),
    caloriesKcal: caloriesKcal,
    averageSpeedKmh: 2,
    photoRelativePath: 'exercise_histories/$id/meter.jpg',
  );
}

void main() {
  final now = DateTime(2026, 11, 10, 15);

  test('運動カロリーは days30 で 2 点になる', () async {
    final result =
        await LoadTrendsUsecaseImpl(
          histories: FixedExerciseHistoryRepository([
            ride(recordedAt: DateTime(2026, 11, 9, 12), caloriesKcal: 100),
            ride(
              recordedAt: DateTime(2026, 11, 10, 12),
              caloriesKcal: 200,
              id: '22222222-2222-4222-8222-222222222222',
            ),
          ]),
          health: FakeHealthBodyMetricsSource(
            status: HealthBodyPermissionStatus.denied,
          ),
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: false,
          ),
        );

    final calories =
        result.exerciseSeries[TrendsMetricKind.exerciseCaloriesKcal]!;
    expect(result.buckets, hasLength(30));
    expect(calories.points, hasLength(2));
    expect(calories.points.first.value, 100);
    expect(calories.points.last.value, 200);
    expect(calories.segments, hasLength(1));
    expect(calories.segments.single.kind, TrendsLineKind.solid);
    expect(result.healthPermission, LoadTrendsHealthPermission.denied);
    expect(result.bodyReadFailed, isFalse);
    expect(result.bodySeries[TrendsMetricKind.bodyWeightKg]!.points, isEmpty);
  });

  test('denied では身体点は空で bodyReadFailed は false', () async {
    final result =
        await LoadTrendsUsecaseImpl(
          histories: const FixedExerciseHistoryRepository([]),
          health: FakeHealthBodyMetricsSource(
            status: HealthBodyPermissionStatus.denied,
            samples: [
              HealthBodySample(
                kind: HealthBodyMetricKind.weightKg,
                at: DateTime(2026, 11, 10, 8),
                value: 70,
              ),
            ],
          ),
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: true,
          ),
        );

    expect(result.healthPermission, LoadTrendsHealthPermission.denied);
    expect(result.bodyReadFailed, isFalse);
    for (final series in result.bodySeries.values) {
      expect(series.points, isEmpty);
    }
  });

  test('throwOnRead で bodyReadFailed が true', () async {
    final result =
        await LoadTrendsUsecaseImpl(
          histories: const FixedExerciseHistoryRepository([]),
          health: FakeHealthBodyMetricsSource(
            status: HealthBodyPermissionStatus.granted,
            throwOnRead: true,
          ),
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: true,
          ),
        );

    expect(result.healthPermission, LoadTrendsHealthPermission.granted);
    expect(result.bodyReadFailed, isTrue);
    expect(result.bodySeries[TrendsMetricKind.bodyWeightKg]!.points, isEmpty);
  });

  test('permissionStatus 失敗でも運動系列を返し bodyReadFailed が true', () async {
    final result =
        await LoadTrendsUsecaseImpl(
          histories: FixedExerciseHistoryRepository([
            ride(recordedAt: DateTime(2026, 11, 10, 12), caloriesKcal: 150),
          ]),
          health: FakeHealthBodyMetricsSource(throwOnPermissionStatus: true),
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: true,
          ),
        );

    expect(result.healthPermission, LoadTrendsHealthPermission.unknown);
    expect(result.bodyReadFailed, isTrue);
    expect(
      result.exerciseSeries[TrendsMetricKind.exerciseCaloriesKcal]!.points,
      hasLength(1),
    );
    expect(result.bodySeries[TrendsMetricKind.bodyWeightKg]!.points, isEmpty);
  });

  test('運動グループかつ granted でも health.read を呼ばない', () async {
    final health = FakeHealthBodyMetricsSource(
      status: HealthBodyPermissionStatus.granted,
      samples: [
        HealthBodySample(
          kind: HealthBodyMetricKind.weightKg,
          at: DateTime(2026, 11, 10, 8),
          value: 70,
        ),
      ],
    );
    final result =
        await LoadTrendsUsecaseImpl(
          histories: const FixedExerciseHistoryRepository([]),
          health: health,
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: false,
          ),
        );

    expect(health.readCallCount, 0);
    expect(result.healthPermission, LoadTrendsHealthPermission.granted);
    expect(result.bodySeries[TrendsMetricKind.bodyWeightKg]!.points, isEmpty);
  });

  test('unknown でも身体グループなら読取を試す', () async {
    final health = FakeHealthBodyMetricsSource(
      status: HealthBodyPermissionStatus.unknown,
      samples: [
        HealthBodySample(
          kind: HealthBodyMetricKind.weightKg,
          at: DateTime(2026, 11, 10, 8),
          value: 71,
        ),
      ],
    );
    final result =
        await LoadTrendsUsecaseImpl(
          histories: const FixedExerciseHistoryRepository([]),
          health: health,
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: true,
          ),
        );

    expect(health.readCallCount, 1);
    expect(
      result.bodySeries[TrendsMetricKind.bodyWeightKg]!.points.single.value,
      71,
    );
  });

  test('granted なら身体の最終値を点にする', () async {
    final result =
        await LoadTrendsUsecaseImpl(
          histories: const FixedExerciseHistoryRepository([]),
          health: FakeHealthBodyMetricsSource(
            status: HealthBodyPermissionStatus.granted,
            samples: [
              HealthBodySample(
                kind: HealthBodyMetricKind.weightKg,
                at: DateTime(2026, 11, 10, 8),
                value: 70,
              ),
              HealthBodySample(
                kind: HealthBodyMetricKind.weightKg,
                at: DateTime(2026, 11, 10, 20),
                value: 69.5,
              ),
              HealthBodySample(
                kind: HealthBodyMetricKind.leanMassKg,
                at: DateTime(2026, 11, 10, 9),
                value: 50,
              ),
            ],
          ),
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: true,
          ),
        );

    expect(
      result.bodySeries[TrendsMetricKind.bodyWeightKg]!.points.single.value,
      69.5,
    );
    expect(
      result.bodySeries[TrendsMetricKind.bodyLeanMassKg]!.points.single.value,
      50,
    );
    expect(result.bodySeries[TrendsMetricKind.bodyFatPercent]!.points, isEmpty);
    expect(result.bodyReadFailed, isFalse);
  });

  test('履歴未許可かつ 90 日なら bodyHistoryLimited', () async {
    final result =
        await LoadTrendsUsecaseImpl(
          histories: const FixedExerciseHistoryRepository([]),
          health: FakeHealthBodyMetricsSource(
            status: HealthBodyPermissionStatus.granted,
            historyAuthorized: false,
          ),
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days90,
            groupIsBody: true,
          ),
        );

    expect(result.bodyHistoryLimited, isTrue);
    expect(result.healthPermission, LoadTrendsHealthPermission.granted);
  });

  test('履歴未許可でも days30 なら bodyHistoryLimited は false', () async {
    final result =
        await LoadTrendsUsecaseImpl(
          histories: const FixedExerciseHistoryRepository([]),
          health: FakeHealthBodyMetricsSource(
            status: HealthBodyPermissionStatus.granted,
            historyAuthorized: false,
          ),
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: true,
          ),
        );

    expect(result.bodyHistoryLimited, isFalse);
  });

  test('granted でも全指標未許可なら bodyPermissionIncomplete', () async {
    final result =
        await LoadTrendsUsecaseImpl(
          histories: const FixedExerciseHistoryRepository([]),
          health: FakeHealthBodyMetricsSource(
            status: HealthBodyPermissionStatus.granted,
            allMetricsAuthorized: false,
          ),
        ).execute(
          LoadTrendsRequest(
            now: now,
            period: TrendsPeriodKind.days30,
            groupIsBody: true,
          ),
        );

    expect(result.bodyPermissionIncomplete, isTrue);
  });
}
