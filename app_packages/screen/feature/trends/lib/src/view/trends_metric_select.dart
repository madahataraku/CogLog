import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/state/trends_metric_set.dart';
import '../viewmodel/state/trends_screen_state.dart';

/// グループに応じた指標組の [FSelect]。
///
/// Example:
/// ```dart
/// TrendsMetricSelect(
///   group: TrendsMetricGroup.exercise,
///   metricSet: TrendsMetricSet.exerciseCalories,
///   onChanged: (_) {},
/// );
/// ```
@internal
class TrendsMetricSelect extends StatelessWidget {
  /// 現在グループ・選択・変更コールバックを受け取る。
  ///
  /// Example:
  /// ```dart
  /// TrendsMetricSelect(
  ///   group: TrendsMetricGroup.body,
  ///   metricSet: TrendsMetricSet.bodyKgPair,
  ///   onChanged: (_) {},
  /// );
  /// ```
  const TrendsMetricSelect({
    super.key,
    required this.group,
    required this.metricSet,
    required this.onChanged,
  });

  /// 運動または身体。
  final TrendsMetricGroup group;

  /// いま選んでいる指標組。
  final TrendsMetricSet metricSet;

  /// 指標組が変わったときの通知。
  final ValueChanged<TrendsMetricSet> onChanged;

  /// グループごとの選択肢を並べる。
  ///
  /// Example:
  /// ```dart
  /// TrendsMetricSelect(
  ///   group: TrendsMetricGroup.exercise,
  ///   metricSet: TrendsMetricSet.exerciseCalories,
  ///   onChanged: (_) {},
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    final items = switch (group) {
      TrendsMetricGroup.exercise => {
        strings.screen_feature_trends_metric_calories:
            TrendsMetricSet.exerciseCalories,
        strings.screen_feature_trends_metric_duration:
            TrendsMetricSet.exerciseDuration,
        strings.screen_feature_trends_metric_distance:
            TrendsMetricSet.exerciseDistance,
      },
      TrendsMetricGroup.body => {
        strings.screen_feature_trends_metric_body_kg:
            TrendsMetricSet.bodyKgPair,
        strings.screen_feature_trends_metric_body_fat: TrendsMetricSet.bodyFat,
      },
    };
    return FSelect<TrendsMetricSet>(
      label: Text(strings.screen_feature_trends_metric_label),
      control: .lifted(
        value: metricSet,
        onChange: (value) {
          if (value == null || value == metricSet) {
            return;
          }
          onChanged(value);
        },
      ),
      items: items,
    );
  }
}
