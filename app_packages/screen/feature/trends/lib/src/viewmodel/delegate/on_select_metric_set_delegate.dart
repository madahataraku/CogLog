import 'package:state_stream/state_stream.dart';

import '../state/trends_metric_set.dart';
import '../state/trends_screen_state.dart';

/// グループ内の指標組を State へ反映する（再取得しない）。
///
/// Example:
/// ```dart
/// OnSelectMetricSetDelegate(state: state)
///     .execute(TrendsMetricSet.exerciseDuration);
/// ```
final class OnSelectMetricSetDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectMetricSetDelegate(state: state);
  /// ```
  const OnSelectMetricSetDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// 現在グループで許される [metricSet] だけを置き換える。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsMetricSet.bodyFat);
  /// ```
  Future<void> execute(TrendsMetricSet metricSet) async {
    await state.updateWithLock((current, emitter) async {
      if (current.metricSet == metricSet) {
        return;
      }
      if (!_allowedForGroup(current.group, metricSet)) {
        return;
      }
      await emitter.emit(current.copyWith(metricSet: metricSet));
    });
  }
}

/// [group] で選べる指標組かどうかを返す。
///
/// Example:
/// ```dart
/// _allowedForGroup(TrendsMetricGroup.exercise, TrendsMetricSet.bodyFat);
/// ```
bool _allowedForGroup(TrendsMetricGroup group, TrendsMetricSet metricSet) {
  return switch (group) {
    TrendsMetricGroup.exercise => switch (metricSet) {
      TrendsMetricSet.exerciseCalories ||
      TrendsMetricSet.exerciseDuration ||
      TrendsMetricSet.exerciseDistance => true,
      TrendsMetricSet.bodyKgPair || TrendsMetricSet.bodyFat => false,
    },
    TrendsMetricGroup.body => switch (metricSet) {
      TrendsMetricSet.bodyKgPair || TrendsMetricSet.bodyFat => true,
      TrendsMetricSet.exerciseCalories ||
      TrendsMetricSet.exerciseDuration ||
      TrendsMetricSet.exerciseDistance => false,
    },
  };
}
