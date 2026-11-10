import 'package:domain_trends/domain_trends.dart';

import '../entity/trends_screen_entity.dart';
import '../entity/trends_visible_series.dart';
import '../state/trends_health_permission_ui.dart';
import '../state/trends_metric_set.dart';
import '../state/trends_screen_state.dart';

/// State を表示用 Entity へ写す。
///
/// Example:
/// ```dart
/// const TrendsStateToEntityDelegate().execute(TrendsScreenState.initial);
/// ```
final class TrendsStateToEntityDelegate {
  /// 変換だけを行う。
  ///
  /// Example:
  /// ```dart
  /// const TrendsStateToEntityDelegate();
  /// ```
  const TrendsStateToEntityDelegate();

  /// [state] の選択・系列・許可フラグを Entity にする。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsScreenState.initial);
  /// ```
  TrendsScreenEntity execute(TrendsScreenState state) {
    final visible = <TrendsVisibleSeries>[];
    switch (state.metricSet) {
      case TrendsMetricSet.exerciseCalories:
        final series =
            state.exerciseSeries[TrendsMetricKind.exerciseCaloriesKcal];
        if (series != null) {
          visible.add(series);
        }
      case TrendsMetricSet.exerciseDuration:
        final series =
            state.exerciseSeries[TrendsMetricKind.exerciseDurationMinutes];
        if (series != null) {
          visible.add(series);
        }
      case TrendsMetricSet.exerciseDistance:
        final series =
            state.exerciseSeries[TrendsMetricKind.exerciseDistanceKm];
        if (series != null) {
          visible.add(series);
        }
      case TrendsMetricSet.bodyKgPair:
        for (final kind in [
          TrendsMetricKind.bodyWeightKg,
          TrendsMetricKind.bodyLeanMassKg,
        ]) {
          final series = state.bodySeries[kind];
          if (series != null) {
            visible.add(series);
          }
        }
      case TrendsMetricSet.bodyFat:
        final series = state.bodySeries[TrendsMetricKind.bodyFatPercent];
        if (series != null) {
          visible.add(series);
        }
    }
    final isBody = state.group == TrendsMetricGroup.body;
    return TrendsScreenEntity(
      period: state.period,
      group: state.group,
      metricSet: state.metricSet,
      loading: state.loading,
      showRequestPermissionButton:
          isBody &&
          state.healthPermissionUi != TrendsHealthPermissionUi.granted &&
          state.healthPermissionUi !=
              TrendsHealthPermissionUi.permanentlyDenied,
      showOpenSettingsButton:
          isBody &&
          state.healthPermissionUi ==
              TrendsHealthPermissionUi.permanentlyDenied,
      showRetryButton: state.bodyReadFailed,
      visibleSeries: visible,
      bucketCount: state.buckets.length,
    );
  }
}
