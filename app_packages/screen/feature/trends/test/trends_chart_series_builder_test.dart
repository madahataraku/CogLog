import 'package:domain_trends/domain_trends.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_trends/src/view/trends_chart_series_builder.dart';
import 'package:screen_feature_trends/src/viewmodel/entity/trends_visible_series.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(LocalizeStringDelegate.resetDelegateForTest);

  test('実線は dashArray 空、点線は 6,4', () {
    final from = TrendsSeriesPoint(
      representativeDate: DateTime(2026, 11, 9),
      value: 1,
    );
    final to = TrendsSeriesPoint(
      representativeDate: DateTime(2026, 11, 10),
      value: 2,
    );
    final series = buildTrendsCartesianSeries(
      series: [
        TrendsVisibleSeries(
          metric: TrendsMetricKind.exerciseCaloriesKcal,
          points: [from, to],
          segments: [
            TrendsLineSegment(from: from, to: to, kind: TrendsLineKind.solid),
            TrendsLineSegment(from: from, to: to, kind: TrendsLineKind.dashed),
          ],
        ),
      ],
      seriesColors: const [Color(0xFF000000)],
    );
    final lines = series.whereType<LineSeries<TrendsSeriesPoint, DateTime>>();
    expect(lines.length, 2);
    expect(lines.first.dashArray, isEmpty);
    expect(lines.last.dashArray, [6.0, 4.0]);
  });

  test('ツールチップ値は浮動小数ノイズを抑え指標桁で整形する', () {
    expect(
      formatTrendsChartValue(
        0.30000000000000004,
        metric: TrendsMetricKind.exerciseDistanceKm,
      ),
      '0.3',
    );
    expect(
      formatTrendsChartValue(
        100.4,
        metric: TrendsMetricKind.exerciseCaloriesKcal,
      ),
      '100',
    );
    expect(
      formatTrendsChartValue(62.56, metric: TrendsMetricKind.bodyWeightKg),
      '62.6',
    );
  });

  test('凡例は Scatter のみ、kcal は left・kg は right', () {
    final point = TrendsSeriesPoint(
      representativeDate: DateTime(2026, 11, 10),
      value: 10,
    );
    final series = buildTrendsCartesianSeries(
      series: [
        TrendsVisibleSeries(
          metric: TrendsMetricKind.exerciseCaloriesKcal,
          points: [point],
          segments: const [],
        ),
        TrendsVisibleSeries(
          metric: TrendsMetricKind.bodyWeightKg,
          points: [point],
          segments: const [],
        ),
      ],
      seriesColors: const [Color(0xFF000000), Color(0xFF111111)],
    );
    final scatters = series
        .whereType<ScatterSeries<TrendsSeriesPoint, DateTime>>()
        .toList();
    expect(scatters, hasLength(2));
    expect(scatters.every((s) => s.isVisibleInLegend), isTrue);
    expect(scatters[0].yAxisName, 'left');
    expect(scatters[1].yAxisName, 'right');
    expect(
      series.whereType<LineSeries<TrendsSeriesPoint, DateTime>>(),
      isEmpty,
    );
  });
}
