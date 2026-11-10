import 'dart:async';

import 'package:domain_trends/domain_trends.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/on_reload_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/on_request_health_permission_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/on_select_group_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/on_select_metric_set_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/on_select_period_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/delegate/trends_state_to_entity_delegate.dart';
import 'package:screen_feature_trends/src/viewmodel/entity/trends_visible_series.dart';
import 'package:screen_feature_trends/src/viewmodel/state/trends_health_permission_ui.dart';
import 'package:screen_feature_trends/src/viewmodel/state/trends_metric_set.dart';
import 'package:screen_feature_trends/src/viewmodel/state/trends_screen_state.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';
import 'package:usecase_request_health_body_permission/usecase_request_health_body_permission.dart';

final class _FakeLoadTrends implements LoadTrendsUsecase {
  LoadTrendsResult? result;
  int calls = 0;
  LoadTrendsRequest? lastRequest;
  Object? throwError;
  Future<void> Function()? onExecute;

  @override
  Future<LoadTrendsResult> execute(LoadTrendsRequest request) async {
    calls += 1;
    lastRequest = request;
    await onExecute?.call();
    final error = throwError;
    if (error != null) {
      throw error;
    }
    return result ??
        const LoadTrendsResult(
          buckets: [],
          exerciseSeries: {},
          bodySeries: {},
          healthPermission: LoadTrendsHealthPermission.unknown,
          bodyReadFailed: false,
        );
  }
}

final class _FakeRequestPermission
    implements RequestHealthBodyPermissionUsecase {
  int calls = 0;
  Object? throwError;

  @override
  Future<HealthBodyPermissionStatus> execute() async {
    calls += 1;
    final error = throwError;
    if (error != null) {
      throw error;
    }
    return HealthBodyPermissionStatus.granted;
  }
}

void main() {
  late MutableStateStream<TrendsScreenState> state;
  late _FakeLoadTrends load;
  final now = DateTime(2026, 11, 10);

  setUp(() {
    state = MutableStateStream(TrendsScreenState.initial);
    load = _FakeLoadTrends();
  });

  tearDown(() async {
    await state.close();
  });

  test('初期値は過去30日・運動・消費カロリー・読込中', () {
    expect(state.state.period, TrendsPeriod.days30);
    expect(state.state.group, TrendsMetricGroup.exercise);
    expect(state.state.metricSet, TrendsMetricSet.exerciseCalories);
    expect(state.state.loading, isTrue);
    final entity = const TrendsStateToEntityDelegate().execute(state.state);
    expect(entity.period, TrendsPeriod.days30);
    expect(entity.group, TrendsMetricGroup.exercise);
    expect(entity.metricSet, TrendsMetricSet.exerciseCalories);
    expect(entity.loading, isTrue);
  });

  test('期間を変えると period が変わり reload する', () async {
    await OnSelectPeriodDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute(TrendsPeriod.days90);
    expect(state.state.period, TrendsPeriod.days90);
    expect(state.state.group, TrendsMetricGroup.exercise);
    expect(load.calls, 1);
    expect(load.lastRequest?.period, TrendsPeriodKind.days90);
    expect(state.state.loading, isFalse);
  });

  test('同じ期間では State も reload もしない', () async {
    await OnSelectPeriodDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute(TrendsPeriod.days90);
    await OnSelectPeriodDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute(TrendsPeriod.days90);
    expect(load.calls, 1);
  });

  test('グループを変えると metricSet を初期へ戻して reload する', () async {
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(metricSet: TrendsMetricSet.exerciseDuration),
      );
    });
    await OnSelectGroupDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute(TrendsMetricGroup.body);
    expect(state.state.group, TrendsMetricGroup.body);
    expect(state.state.metricSet, TrendsMetricSet.bodyKgPair);
    expect(load.calls, 1);
    expect(load.lastRequest?.groupIsBody, isTrue);
  });

  test('同じグループでは State も reload もしない', () async {
    await OnSelectGroupDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute(TrendsMetricGroup.body);
    await OnSelectGroupDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute(TrendsMetricGroup.body);
    expect(load.calls, 1);
  });

  test('指標組切替は reload せず visible だけ変わる', () async {
    const calories = TrendsVisibleSeries(
      metric: TrendsMetricKind.exerciseCaloriesKcal,
      points: [],
      segments: [],
    );
    const duration = TrendsVisibleSeries(
      metric: TrendsMetricKind.exerciseDurationMinutes,
      points: [],
      segments: [],
    );
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          loading: false,
          exerciseSeries: {
            TrendsMetricKind.exerciseCaloriesKcal: calories,
            TrendsMetricKind.exerciseDurationMinutes: duration,
          },
        ),
      );
    });
    await OnSelectMetricSetDelegate(state: state)
        .execute(TrendsMetricSet.exerciseDuration);
    expect(state.state.metricSet, TrendsMetricSet.exerciseDuration);
    expect(load.calls, 0);
    final entity = const TrendsStateToEntityDelegate().execute(state.state);
    expect(
      entity.visibleSeries.single.metric,
      TrendsMetricKind.exerciseDurationMinutes,
    );
  });

  test('身体グループで拒否なら許可ボタン、永久拒否なら設定ボタン', () {
    final denied = const TrendsStateToEntityDelegate().execute(
      TrendsScreenState.initial.copyWith(
        group: TrendsMetricGroup.body,
        metricSet: TrendsMetricSet.bodyKgPair,
        loading: false,
        healthPermissionUi: TrendsHealthPermissionUi.denied,
      ),
    );
    expect(denied.showRequestPermissionButton, isTrue);
    expect(denied.showOpenSettingsButton, isFalse);

    final permanent = const TrendsStateToEntityDelegate().execute(
      TrendsScreenState.initial.copyWith(
        group: TrendsMetricGroup.body,
        metricSet: TrendsMetricSet.bodyKgPair,
        loading: false,
        healthPermissionUi: TrendsHealthPermissionUi.permanentlyDenied,
      ),
    );
    expect(permanent.showRequestPermissionButton, isFalse);
    expect(permanent.showOpenSettingsButton, isTrue);
  });

  test('読取失敗なら再試行ボタン', () {
    final body = const TrendsStateToEntityDelegate().execute(
      TrendsScreenState.initial.copyWith(
        group: TrendsMetricGroup.body,
        metricSet: TrendsMetricSet.bodyKgPair,
        loading: false,
        bodyReadFailed: true,
        healthPermissionUi: TrendsHealthPermissionUi.granted,
      ),
    );
    expect(body.showRetryButton, isTrue);

    final exercise = const TrendsStateToEntityDelegate().execute(
      TrendsScreenState.initial.copyWith(loading: false, bodyReadFailed: true),
    );
    expect(exercise.showRetryButton, isTrue);
  });

  test('許可リクエスト後に reload する', () async {
    final request = _FakeRequestPermission();
    await OnRequestHealthPermissionDelegate(
      state: state,
      requestHealthPermissionUsecase: request,
      loadTrendsUsecase: load,
      now: now,
    ).execute();
    expect(request.calls, 1);
    expect(load.calls, 1);
  });

  test('許可リクエスト失敗時は reload せず bodyReadFailed を立てる', () async {
    final request = _FakeRequestPermission()
      ..throwError = StateError('permission failed');
    await OnRequestHealthPermissionDelegate(
      state: state,
      requestHealthPermissionUsecase: request,
      loadTrendsUsecase: load,
      now: now,
    ).execute();
    expect(request.calls, 1);
    expect(load.calls, 0);
    expect(state.state.bodyReadFailed, isTrue);
    expect(state.state.loading, isTrue);
  });

  test('OnReloadDelegate は系列と許可を State へ書く', () async {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: now,
      spec: TrendsPeriodSpec.days30,
    );
    load.result = LoadTrendsResult(
      buckets: buckets,
      exerciseSeries: {
        TrendsMetricKind.exerciseCaloriesKcal: const LoadTrendsSeries(
          metric: TrendsMetricKind.exerciseCaloriesKcal,
          points: [],
          segments: [],
        ),
      },
      bodySeries: const {},
      healthPermission: LoadTrendsHealthPermission.denied,
      bodyReadFailed: false,
    );
    await OnReloadDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute();
    expect(state.state.loading, isFalse);
    expect(state.state.buckets.length, buckets.length);
    expect(
      state.state.exerciseSeries[TrendsMetricKind.exerciseCaloriesKcal],
      isNotNull,
    );
    expect(state.state.healthPermissionUi, TrendsHealthPermissionUi.denied);
  });

  test('OnReloadDelegate は失敗時に loading を下ろし bodyReadFailed を立てる', () async {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: now,
      spec: TrendsPeriodSpec.days30,
    );
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          loading: false,
          buckets: buckets,
          exerciseSeries: {
            TrendsMetricKind.exerciseCaloriesKcal: const TrendsVisibleSeries(
              metric: TrendsMetricKind.exerciseCaloriesKcal,
              points: [],
              segments: [],
            ),
          },
        ),
      );
    });
    load.throwError = StateError('reload failed');
    await OnReloadDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute();
    expect(state.state.loading, isFalse);
    expect(state.state.bodyReadFailed, isTrue);
    expect(state.state.buckets, isEmpty);
    expect(state.state.exerciseSeries, isEmpty);
    expect(state.state.bodySeries, isEmpty);
  });

  test('OnReloadDelegate は期間変更後の古い結果を捨てる', () async {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: now,
      spec: TrendsPeriodSpec.days30,
    );
    load
      ..result = LoadTrendsResult(
        buckets: buckets,
        exerciseSeries: const {},
        bodySeries: const {},
        healthPermission: LoadTrendsHealthPermission.granted,
        bodyReadFailed: false,
      )
      ..onExecute = () async {
        await state.updateWithLock((current, emitter) async {
          await emitter.emit(current.copyWith(period: TrendsPeriod.days90));
        });
      };
    await OnReloadDelegate(
      state: state,
      loadTrendsUsecase: load,
      now: now,
    ).execute();
    expect(state.state.period, TrendsPeriod.days90);
    expect(state.state.buckets, isEmpty);
    expect(state.state.loading, isTrue);
  });

  test('OnReloadDelegate は同一条件の古い失敗で最新成功を上書きしない', () async {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: now,
      spec: TrendsPeriodSpec.days30,
    );
    final first = _FakeLoadTrends()
      ..throwError = StateError('stale reload failed');
    final second = _FakeLoadTrends()
      ..result = LoadTrendsResult(
        buckets: buckets,
        exerciseSeries: {
          TrendsMetricKind.exerciseCaloriesKcal: const LoadTrendsSeries(
            metric: TrendsMetricKind.exerciseCaloriesKcal,
            points: [],
            segments: [],
          ),
        },
        bodySeries: const {},
        healthPermission: LoadTrendsHealthPermission.granted,
        bodyReadFailed: false,
      );

    late void Function() finishFirst;
    final firstStarted = Completer<void>();
    first.onExecute = () {
      firstStarted.complete();
      final gate = Completer<void>();
      finishFirst = gate.complete;
      return gate.future;
    };

    final firstFuture = OnReloadDelegate(
      state: state,
      loadTrendsUsecase: first,
      now: now,
    ).execute();
    await firstStarted.future;

    await OnReloadDelegate(
      state: state,
      loadTrendsUsecase: second,
      now: now,
    ).execute();
    expect(state.state.loading, isFalse);
    expect(state.state.bodyReadFailed, isFalse);
    expect(state.state.buckets.length, buckets.length);
    expect(state.state.reloadGeneration, 2);

    finishFirst();
    await firstFuture;
    expect(state.state.loading, isFalse);
    expect(state.state.bodyReadFailed, isFalse);
    expect(state.state.buckets.length, buckets.length);
    expect(state.state.reloadGeneration, 2);
  });
}
