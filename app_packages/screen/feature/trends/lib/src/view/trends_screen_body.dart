import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/state/trends_screen_state.dart';
import '../viewmodel/trends_screen_view_model.dart';
import 'trends_screen_providers.dart';

/// 期間・グループの選択とグラフ準備中プレースホルダ。
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

  /// 期間とグループの [FSelect] とプレースホルダを並べる。
  ///
  /// Example:
  /// ```dart
  /// const TrendsScreenBody();
  /// ```
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = ref.watch(TrendsScreenProviders.entity);
    final viewModel = ref.read(TrendsScreenViewModel.provider);
    return FScaffold(
      header: FHeader(title: Text(strings.screen_feature_trends_title)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            FSelect<TrendsPeriod>(
              label: Text(strings.screen_feature_trends_period_label),
              control: .lifted(
                value: entity.period,
                onChange: (period) async {
                  if (period == null || period == entity.period) {
                    return;
                  }
                  await viewModel.onSelectPeriod(period);
                },
              ),
              items: {
                strings.screen_feature_trends_period_days30:
                    TrendsPeriod.days30,
                strings.screen_feature_trends_period_days90:
                    TrendsPeriod.days90,
                strings.screen_feature_trends_period_days182:
                    TrendsPeriod.days182,
                strings.screen_feature_trends_period_days365:
                    TrendsPeriod.days365,
              },
            ),
            FSelect<TrendsMetricGroup>(
              label: Text(strings.screen_feature_trends_group_label),
              control: .lifted(
                value: entity.group,
                onChange: (group) async {
                  if (group == null || group == entity.group) {
                    return;
                  }
                  await viewModel.onSelectGroup(group);
                },
              ),
              items: {
                strings.screen_feature_trends_group_exercise:
                    TrendsMetricGroup.exercise,
                strings.screen_feature_trends_group_body:
                    TrendsMetricGroup.body,
              },
            ),
            Expanded(
              child: Center(
                child: Text(strings.screen_feature_trends_chart_placeholder),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
