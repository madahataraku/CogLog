import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/state/trends_screen_state.dart';
import '../viewmodel/trends_screen_view_model.dart';
import 'trends_chart.dart';
import 'trends_metric_select.dart';
import 'trends_screen_providers.dart';

/// 期間・グループ・指標の選択と許可ボタン・グラフ。
///
/// Example:
/// ```dart
/// const TrendsScreenBody();
/// ```
@internal
class TrendsScreenBody extends ConsumerWidget {
  /// 本文を作る。
  ///
  /// Example:
  /// ```dart
  /// const TrendsScreenBody();
  /// ```
  const TrendsScreenBody({super.key});

  /// 選択 UI・条件付きボタン・[TrendsChart] を並べる。
  ///
  /// Example:
  /// ```dart
  /// const TrendsScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(TrendsScreenProviders.entity);
    final screenState = ref.watch(TrendsScreenProviders.state);
    final viewModel = ref.read(TrendsScreenViewModel.provider);
    return FScaffold(
      header: FHeader(title: Text(strings.screen_feature_trends_title)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            FSelectMenuTile<TrendsPeriod>.fromMap(
              {
                strings.screen_feature_trends_period_days30:
                    TrendsPeriod.days30,
                strings.screen_feature_trends_period_days90:
                    TrendsPeriod.days90,
                strings.screen_feature_trends_period_days182:
                    TrendsPeriod.days182,
                strings.screen_feature_trends_period_days365:
                    TrendsPeriod.days365,
              },
              title: Text(strings.screen_feature_trends_period_label),
              details: Text(switch (entity.period) {
                TrendsPeriod.days30 =>
                  strings.screen_feature_trends_period_days30,
                TrendsPeriod.days90 =>
                  strings.screen_feature_trends_period_days90,
                TrendsPeriod.days182 =>
                  strings.screen_feature_trends_period_days182,
                TrendsPeriod.days365 =>
                  strings.screen_feature_trends_period_days365,
              }),
              selectControl: .lifted(
                value: {entity.period},
                onChange: (values) async {
                  final period = values.difference({entity.period}).firstOrNull;
                  if (period == null || period == entity.period) {
                    return;
                  }
                  await viewModel.onSelectPeriod(period);
                },
              ),
            ),
            FSelectMenuTile<TrendsMetricGroup>.fromMap(
              {
                strings.screen_feature_trends_group_exercise:
                    TrendsMetricGroup.exercise,
                strings.screen_feature_trends_group_body:
                    TrendsMetricGroup.body,
              },
              title: Text(strings.screen_feature_trends_group_label),
              details: Text(switch (entity.group) {
                TrendsMetricGroup.exercise =>
                  strings.screen_feature_trends_group_exercise,
                TrendsMetricGroup.body =>
                  strings.screen_feature_trends_group_body,
              }),
              selectControl: .lifted(
                value: {entity.group},
                onChange: (values) async {
                  final group = values.difference({entity.group}).firstOrNull;
                  if (group == null || group == entity.group) {
                    return;
                  }
                  await viewModel.onSelectGroup(group);
                },
              ),
            ),
            TrendsMetricSelect(
              group: entity.group,
              metricSet: entity.metricSet,
              onChanged: viewModel.onSelectMetricSet,
            ),
            if (entity.showRequestPermissionButton)
              FButton(
                onPress: viewModel.onRequestHealthPermission,
                child: Text(
                  strings.screen_feature_trends_request_health_permission,
                ),
              ),
            if (entity.showRequestHistoryButton)
              FButton(
                onPress: viewModel.onRequestHealthPermission,
                child: Text(
                  strings.screen_feature_trends_request_health_history,
                ),
              ),
            if (entity.showOpenSettingsButton)
              FButton(
                onPress: viewModel.onOpenAppSettings,
                child: Text(strings.screen_feature_trends_open_os_settings),
              ),
            if (entity.showRetryButton)
              FButton(
                onPress: viewModel.onRetry,
                child: Text(strings.screen_feature_trends_retry_load),
              ),
            Expanded(
              child: TrendsChart(
                loading: entity.loading,
                buckets: screenState.buckets,
                series: entity.visibleSeries,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
