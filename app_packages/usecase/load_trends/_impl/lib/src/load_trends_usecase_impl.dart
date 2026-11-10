import 'package:data_repository_exercise_history/data_repository_exercise_history.dart';
import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:domain_trends/domain_trends.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';

/// Repository とヘルスソースから推移系列を読む。
///
/// Example:
/// ```dart
/// LoadTrendsUsecaseImpl(
///   histories: histories,
///   health: health,
/// ).execute(
///   LoadTrendsRequest(
///     now: DateTime(2026, 11, 10),
///     period: TrendsPeriodKind.days30,
///     groupIsBody: false,
///   ),
/// );
/// ```
final class LoadTrendsUsecaseImpl implements LoadTrendsUsecase {
  /// [histories] と [health] を読む実装を作る。
  ///
  /// Example:
  /// ```dart
  /// LoadTrendsUsecaseImpl(histories: histories, health: health);
  /// ```
  const LoadTrendsUsecaseImpl({required this.histories, required this.health});

  /// 運動履歴の読み出し。
  final ExerciseHistoryRepository histories;

  /// 身体指標の許可と読取。
  final HealthBodyMetricsSource health;

  static const _exerciseMetrics = <TrendsMetricKind>[
    TrendsMetricKind.exerciseDurationMinutes,
    TrendsMetricKind.exerciseDistanceKm,
    TrendsMetricKind.exerciseCaloriesKcal,
  ];

  static const _bodyMetrics = <TrendsMetricKind>[
    TrendsMetricKind.bodyWeightKg,
    TrendsMetricKind.bodyFatPercent,
    TrendsMetricKind.bodyLeanMassKg,
  ];

  /// 運動は常に集約し、許可時だけ身体を読む。
  ///
  /// Example:
  /// ```dart
  /// usecase.execute(
  ///   LoadTrendsRequest(
  ///     now: DateTime(2026, 11, 10),
  ///     period: TrendsPeriodKind.days30,
  ///     groupIsBody: false,
  ///   ),
  /// );
  /// ```
  @override
  Future<LoadTrendsResult> execute(LoadTrendsRequest request) async {
    final spec = TrendsPeriodSpec.of(request.period);
    final buckets = TrendsBucketBuilder.build(
      nowLocal: request.now,
      spec: spec,
    );
    final all = await histories.list();
    final exerciseSeries = <TrendsMetricKind, LoadTrendsSeries>{
      for (final metric in _exerciseMetrics)
        metric: _exerciseSeries(
          metric: metric,
          histories: all,
          buckets: buckets,
        ),
    };

    late final LoadTrendsHealthPermission healthPermission;
    try {
      healthPermission = _mapFromInfra(await health.permissionStatus());
    } catch (_) {
      return LoadTrendsResult(
        buckets: buckets,
        exerciseSeries: exerciseSeries,
        bodySeries: _emptyBodySeries(buckets),
        healthPermission: LoadTrendsHealthPermission.unknown,
        bodyReadFailed: true,
      );
    }
    final bodyHistoryLimited = await _bodyHistoryLimited(
      groupIsBody: request.groupIsBody,
      period: request.period,
    );
    // 運動グループでは身体を読まない。iOS は READ が unknown のままなので、
    // 身体グループでは granted / unknown のとき読取を試す。
    final canAttemptBodyRead =
        request.groupIsBody &&
        buckets.isNotEmpty &&
        (healthPermission == LoadTrendsHealthPermission.granted ||
            healthPermission == LoadTrendsHealthPermission.unknown);
    if (!canAttemptBodyRead) {
      return LoadTrendsResult(
        buckets: buckets,
        exerciseSeries: exerciseSeries,
        bodySeries: _emptyBodySeries(buckets),
        healthPermission: healthPermission,
        bodyReadFailed: false,
        bodyHistoryLimited: bodyHistoryLimited,
      );
    }

    try {
      final samples = await health.read(
        startInclusive: buckets.first.startInclusive,
        endExclusive: buckets.last.endExclusive,
      );
      return LoadTrendsResult(
        buckets: buckets,
        exerciseSeries: exerciseSeries,
        bodySeries: _bodySeries(samples: samples, buckets: buckets),
        healthPermission: healthPermission,
        bodyReadFailed: false,
        bodyHistoryLimited: bodyHistoryLimited,
      );
    } on HealthBodyMetricsReadException {
      return LoadTrendsResult(
        buckets: buckets,
        exerciseSeries: exerciseSeries,
        bodySeries: _emptyBodySeries(buckets),
        healthPermission: healthPermission,
        bodyReadFailed: true,
        bodyHistoryLimited: bodyHistoryLimited,
      );
    }
  }

  /// 身体グループかつ 30 日超の期間で履歴許可が無いとき true。
  Future<bool> _bodyHistoryLimited({
    required bool groupIsBody,
    required TrendsPeriodKind period,
  }) async {
    if (!groupIsBody || period == TrendsPeriodKind.days30) {
      return false;
    }
    try {
      return !(await health.isHistoryAuthorized());
    } catch (_) {
      return true;
    }
  }

  /// infra の許可状態を usecase 境界の型へ写す。
  LoadTrendsHealthPermission _mapFromInfra(HealthBodyPermissionStatus status) {
    return switch (status) {
      HealthBodyPermissionStatus.unknown => LoadTrendsHealthPermission.unknown,
      HealthBodyPermissionStatus.granted => LoadTrendsHealthPermission.granted,
      HealthBodyPermissionStatus.denied => LoadTrendsHealthPermission.denied,
      HealthBodyPermissionStatus.permanentlyDenied =>
        LoadTrendsHealthPermission.permanentlyDenied,
    };
  }

  /// 運動履歴から 1 指標の系列を作る。
  LoadTrendsSeries _exerciseSeries({
    required TrendsMetricKind metric,
    required List<ExerciseHistory> histories,
    required List<TrendsBucket> buckets,
  }) {
    final samples = switch (metric) {
      TrendsMetricKind.exerciseDurationMinutes => [
        for (final history in histories)
          TrendsSample(
            at: history.recordedAt,
            value: history.duration.inMinutes.toDouble(),
          ),
      ],
      TrendsMetricKind.exerciseDistanceKm => [
        for (final history in histories)
          TrendsSample(at: history.recordedAt, value: history.distanceKm),
      ],
      TrendsMetricKind.exerciseCaloriesKcal => [
        for (final history in histories)
          TrendsSample(at: history.recordedAt, value: history.caloriesKcal),
      ],
      _ => const <TrendsSample>[],
    };
    final points = TrendsExerciseAggregator.points(
      samples: samples,
      buckets: buckets,
    );
    return LoadTrendsSeries(
      metric: metric,
      points: points,
      segments: TrendsLineBuilder.segments(points: points, buckets: buckets),
    );
  }

  /// ヘルスサンプルから身体 3 指標の系列を作る。
  Map<TrendsMetricKind, LoadTrendsSeries> _bodySeries({
    required List<HealthBodySample> samples,
    required List<TrendsBucket> buckets,
  }) {
    return {
      for (final metric in _bodyMetrics)
        metric: _bodyMetricSeries(
          metric: metric,
          samples: samples,
          buckets: buckets,
        ),
    };
  }

  /// 1 身体指標の系列を作る。
  LoadTrendsSeries _bodyMetricSeries({
    required TrendsMetricKind metric,
    required List<HealthBodySample> samples,
    required List<TrendsBucket> buckets,
  }) {
    final kind = switch (metric) {
      TrendsMetricKind.bodyWeightKg => HealthBodyMetricKind.weightKg,
      TrendsMetricKind.bodyFatPercent => HealthBodyMetricKind.bodyFatPercent,
      TrendsMetricKind.bodyLeanMassKg => HealthBodyMetricKind.leanMassKg,
      _ => null,
    };
    final trendsSamples = [
      for (final sample in samples)
        if (sample.kind == kind)
          TrendsSample(at: sample.at, value: sample.value),
    ];
    final points = TrendsBodyAggregator.points(
      samples: trendsSamples,
      buckets: buckets,
    );
    return LoadTrendsSeries(
      metric: metric,
      points: points,
      segments: TrendsLineBuilder.segments(points: points, buckets: buckets),
    );
  }

  /// 点なしの身体 3 系列を返す。
  Map<TrendsMetricKind, LoadTrendsSeries> _emptyBodySeries(
    List<TrendsBucket> buckets,
  ) {
    return {
      for (final metric in _bodyMetrics)
        metric: LoadTrendsSeries(
          metric: metric,
          points: const [],
          segments: TrendsLineBuilder.segments(
            points: const [],
            buckets: buckets,
          ),
        ),
    };
  }
}
