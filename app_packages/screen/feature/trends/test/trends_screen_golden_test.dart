import 'package:domain_trends/domain_trends.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart';
import 'package:infra_health_body_metrics/infra_health_body_metrics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_trends/screen_feature_trends.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';
import 'package:usecase_open_app_settings/usecase_open_app_settings.dart';
import 'package:usecase_request_health_body_permission/usecase_request_health_body_permission.dart';

final class _FakeLoadTrends implements LoadTrendsUsecase {
  _FakeLoadTrends(this.result);

  final LoadTrendsResult result;

  @override
  Future<LoadTrendsResult> execute(LoadTrendsRequest request) async => result;
}

final class _FakeRequestPermission
    implements RequestHealthBodyPermissionUsecase {
  @override
  Future<HealthBodyPermissionStatus> execute() async =>
      HealthBodyPermissionStatus.denied;
}

final class _FakeOpenSettings implements OpenAppSettingsUsecase {
  @override
  Future<void> execute() async {}
}

LoadTrendsSeries _emptySeries(TrendsMetricKind metric) =>
    LoadTrendsSeries(metric: metric, points: const [], segments: const []);

LoadTrendsResult _emptyExerciseResult({
  LoadTrendsHealthPermission permission = LoadTrendsHealthPermission.unknown,
}) {
  final now = DateTime(2026, 11, 10);
  final buckets = TrendsBucketBuilder.build(
    nowLocal: now,
    spec: TrendsPeriodSpec.days30,
  );
  return LoadTrendsResult(
    buckets: buckets,
    exerciseSeries: {
      TrendsMetricKind.exerciseCaloriesKcal: _emptySeries(
        TrendsMetricKind.exerciseCaloriesKcal,
      ),
      TrendsMetricKind.exerciseDurationMinutes: _emptySeries(
        TrendsMetricKind.exerciseDurationMinutes,
      ),
      TrendsMetricKind.exerciseDistanceKm: _emptySeries(
        TrendsMetricKind.exerciseDistanceKm,
      ),
    },
    bodySeries: {
      TrendsMetricKind.bodyWeightKg: _emptySeries(
        TrendsMetricKind.bodyWeightKg,
      ),
      TrendsMetricKind.bodyFatPercent: _emptySeries(
        TrendsMetricKind.bodyFatPercent,
      ),
      TrendsMetricKind.bodyLeanMassKg: _emptySeries(
        TrendsMetricKind.bodyLeanMassKg,
      ),
    },
    healthPermission: permission,
    bodyReadFailed: false,
  );
}

LoadTrendsResult _withPointsResult() {
  final now = DateTime(2026, 11, 10);
  final buckets = TrendsBucketBuilder.build(
    nowLocal: now,
    spec: TrendsPeriodSpec.days30,
  );
  final p1 = TrendsSeriesPoint(
    representativeDate: buckets[buckets.length - 2].representativeDate,
    value: 100,
  );
  final p2 = TrendsSeriesPoint(
    representativeDate: buckets.last.representativeDate,
    value: 200,
  );
  final calories = LoadTrendsSeries(
    metric: TrendsMetricKind.exerciseCaloriesKcal,
    points: [p1, p2],
    segments: [TrendsLineSegment(from: p1, to: p2, kind: TrendsLineKind.solid)],
  );
  return LoadTrendsResult(
    buckets: buckets,
    exerciseSeries: {
      TrendsMetricKind.exerciseCaloriesKcal: calories,
      TrendsMetricKind.exerciseDurationMinutes: _emptySeries(
        TrendsMetricKind.exerciseDurationMinutes,
      ),
      TrendsMetricKind.exerciseDistanceKm: _emptySeries(
        TrendsMetricKind.exerciseDistanceKm,
      ),
    },
    bodySeries: {
      TrendsMetricKind.bodyWeightKg: _emptySeries(
        TrendsMetricKind.bodyWeightKg,
      ),
      TrendsMetricKind.bodyFatPercent: _emptySeries(
        TrendsMetricKind.bodyFatPercent,
      ),
      TrendsMetricKind.bodyLeanMassKg: _emptySeries(
        TrendsMetricKind.bodyLeanMassKg,
      ),
    },
    healthPermission: LoadTrendsHealthPermission.unknown,
    bodyReadFailed: false,
  );
}

List<Override> _overrides(LoadTrendsResult result) => [
  LoadTrendsUsecase.provider.overrideWith((ref) => _FakeLoadTrends(result)),
  RequestHealthBodyPermissionUsecase.provider.overrideWith(
    (ref) => _FakeRequestPermission(),
  ),
  OpenAppSettingsUsecase.provider.overrideWith((ref) => _FakeOpenSettings()),
];

Future<void> _prepareSurface(WidgetTester tester) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('ja')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await LocalizeStringDelegate.injectDelegateForTest(
    arbJson: StringsTestHelper.ja,
  );
  addTearDown(LocalizeStringDelegate.resetDelegateForTest);
}

Widget _wrap(Widget child) => ShellTabIndexScope(
  index: 2,
  child: MaterialApp(
    locale: const Locale('ja'),
    home: FTheme(
      data: FThemeData(touch: true, colors: FColors.neutralLight),
      child: child,
    ),
  ),
);

void main() {
  testWidgets('推移 運動・空点 / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(_emptyExerciseResult()),
          child: _wrap(const TrendsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(TrendsScreen),
        matchesGoldenFile('goldens/trends_screen_default.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('推移 比較1・許可ボタン / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(
            _emptyExerciseResult(permission: LoadTrendsHealthPermission.denied),
          ),
          child: _wrap(const TrendsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(TrendsScreen),
        matchesGoldenFile('goldens/trends_screen_body_permission.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('推移 運動・点あり / ja / Android / light', (tester) async {
    await _prepareSurface(tester);
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: _overrides(_withPointsResult()),
          child: _wrap(const TrendsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(TrendsScreen),
        matchesGoldenFile('goldens/trends_screen_with_points.png'),
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
