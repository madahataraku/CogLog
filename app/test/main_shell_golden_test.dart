import 'package:domain_trends/domain_trends.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_feature_main/screen_feature_main.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';

import 'top_screen_harness.dart';

/// 推移 Golden 用。軸ラベルが [DateTime.now] 依存で日々ずれないよう日時を固定する。
final class _FixedEmptyLoadTrends implements LoadTrendsUsecase {
  static final _now = DateTime(2026, 11, 10);

  LoadTrendsSeries _empty(TrendsMetricKind metric) =>
      LoadTrendsSeries(metric: metric, points: const [], segments: const []);

  @override
  Future<LoadTrendsResult> execute(LoadTrendsRequest request) async {
    final buckets = TrendsBucketBuilder.build(
      nowLocal: _now,
      spec: TrendsPeriodSpec.of(request.period),
    );
    return LoadTrendsResult(
      buckets: buckets,
      exerciseSeries: {
        TrendsMetricKind.exerciseCaloriesKcal: _empty(
          TrendsMetricKind.exerciseCaloriesKcal,
        ),
        TrendsMetricKind.exerciseDurationMinutes: _empty(
          TrendsMetricKind.exerciseDurationMinutes,
        ),
        TrendsMetricKind.exerciseDistanceKm: _empty(
          TrendsMetricKind.exerciseDistanceKm,
        ),
      },
      bodySeries: {
        TrendsMetricKind.bodyWeightKg: _empty(TrendsMetricKind.bodyWeightKg),
        TrendsMetricKind.bodyFatPercent: _empty(
          TrendsMetricKind.bodyFatPercent,
        ),
        TrendsMetricKind.bodyLeanMassKg: _empty(
          TrendsMetricKind.bodyLeanMassKg,
        ),
      },
      // harness の FakeHealthBodyMetricsSource と同じ denied。
      healthPermission: LoadTrendsHealthPermission.denied,
      bodyReadFailed: false,
    );
  }
}

void main() {
  for (final brightness in [Brightness.light, Brightness.dark]) {
    final golden = brightness == Brightness.light
        ? 'goldens/main_shell_home.png'
        : 'goldens/main_shell_home_dark.png';
    testWidgets('シェル付きホームの $brightness / ja / Android の空状態', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      tester.platformDispatcher.platformBrightnessTestValue = brightness;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      tester.platformDispatcher.localesTestValue = const [Locale('ja')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      try {
        await pumpTopScreen(tester);
        await expectLater(
          find.byType(MainShellScreen),
          matchesGoldenFile(golden),
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  testWidgets('メーター記録タブの空画面', (tester) async {
    await _pumpTabGolden(
      tester,
      tab: 'メーター記録',
      golden: 'goldens/main_shell_meter_capture.png',
    );
  });

  testWidgets('推移タブの空画面', (tester) async {
    await _pumpTabGolden(
      tester,
      tab: '推移',
      golden: 'goldens/main_shell_trends.png',
      loadTrends: _FixedEmptyLoadTrends(),
    );
  });

  testWidgets('運動履歴タブの空画面', (tester) async {
    await _pumpTabGolden(
      tester,
      tab: '運動履歴',
      golden: 'goldens/main_shell_exercise_history.png',
    );
  });

  testWidgets('目標設定タブの空画面', (tester) async {
    await _pumpTabGolden(
      tester,
      tab: '目標設定',
      golden: 'goldens/main_shell_goal_settings.png',
    );
  });
}

Future<void> _pumpTabGolden(
  WidgetTester tester, {
  required String tab,
  required String golden,
  LoadTrendsUsecase? loadTrends,
}) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
  tester.platformDispatcher.localesTestValue = const [Locale('ja')];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  try {
    await pumpTopScreen(tester, loadTrends: loadTrends);
    await tester.tap(find.text(tab).last);
    // メーター記録のカメラ初期化中は progress が回り続けるため settle しない。
    // 推移タブは Syncfusion チャートがあるので、残 Timer を捨てるまで待つ。
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    if (tab == '推移') {
      await tester.pumpAndSettle();
    }
    await expectLater(find.byType(MainShellScreen), matchesGoldenFile(golden));
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}
