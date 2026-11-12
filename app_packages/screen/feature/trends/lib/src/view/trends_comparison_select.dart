import 'package:forui/forui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:meta/meta.dart';

import '../strings.dart';
import '../viewmodel/state/trends_comparison.dart';

/// 比較プリセットの [FSelectMenuTile]。
///
/// Example:
/// ```dart
/// TrendsComparisonSelect(
///   comparison: TrendsComparison.caloriesBodyKg,
///   onChanged: (_) {},
/// );
/// ```
@internal
class TrendsComparisonSelect extends StatelessWidget {
  /// 現在選択と比較変更コールバックを受け取る。
  ///
  /// Example:
  /// ```dart
  /// TrendsComparisonSelect(
  ///   comparison: TrendsComparison.caloriesBodyFat,
  ///   onChanged: (_) {},
  /// );
  /// ```
  const TrendsComparisonSelect({
    super.key,
    required this.comparison,
    required this.onChanged,
  });

  /// いま選んでいる比較。
  final TrendsComparison comparison;

  /// 比較が変わったときの通知。
  final ValueChanged<TrendsComparison> onChanged;

  /// 比較の選択肢を並べる。
  ///
  /// Example:
  /// ```dart
  /// TrendsComparisonSelect(
  ///   comparison: TrendsComparison.caloriesBodyKg,
  ///   onChanged: (_) {},
  /// );
  /// ```
  @override
  Widget build(BuildContext context) {
    final items = {
      strings.screen_feature_trends_comparison_calories_body_kg:
          TrendsComparison.caloriesBodyKg,
      strings.screen_feature_trends_comparison_calories_body_fat:
          TrendsComparison.caloriesBodyFat,
      strings.screen_feature_trends_comparison_duration_distance:
          TrendsComparison.durationDistance,
    };
    final detailsLabel = items.entries
        .firstWhere((entry) => entry.value == comparison)
        .key;
    return FSelectMenuTile<TrendsComparison>.fromMap(
      items,
      title: Text(strings.screen_feature_trends_comparison_label),
      details: Text(detailsLabel),
      selectControl: .lifted(
        value: {comparison},
        onChange: (values) {
          final next = values.difference({comparison}).firstOrNull;
          if (next == null || next == comparison) {
            return;
          }
          onChanged(next);
        },
      ),
    );
  }
}
