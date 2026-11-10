import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';

import '../state/trends_metric_set.dart';
import '../state/trends_screen_state.dart';
import 'on_reload_delegate.dart';

/// 指標グループ選択を State へ反映し、系列を読み直す。
///
/// Example:
/// ```dart
/// OnSelectGroupDelegate(
///   state: state,
///   loadTrendsUsecase: loadTrendsUsecase,
///   now: DateTime(2026, 11, 10),
/// ).execute(TrendsMetricGroup.body);
/// ```
final class OnSelectGroupDelegate {
  /// [state]・読込 Usecase・基準時刻を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectGroupDelegate(
  ///   state: state,
  ///   loadTrendsUsecase: loadTrendsUsecase,
  ///   now: DateTime(2026, 11, 10),
  /// );
  /// ```
  const OnSelectGroupDelegate({
    required this.state,
    required this.loadTrendsUsecase,
    required this.now,
  });

  /// 更新する画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// 系列の読み込み。
  final LoadTrendsUsecase loadTrendsUsecase;

  /// バケット境界に使う時刻。
  final DateTime now;

  /// [group] が現在と違うときだけ置き換え、指標組を初期へ戻して読み直す。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsMetricGroup.body);
  /// ```
  Future<void> execute(TrendsMetricGroup group) async {
    final changed = await state.updateWithLock((current, emitter) async {
      if (current.group == group) {
        return false;
      }
      final metricSet = switch (group) {
        TrendsMetricGroup.exercise => TrendsMetricSet.exerciseCalories,
        TrendsMetricGroup.body => TrendsMetricSet.bodyKgPair,
      };
      await emitter.emit(current.copyWith(group: group, metricSet: metricSet));
      return true;
    });
    if (!changed) {
      return;
    }
    await OnReloadDelegate(
      state: state,
      loadTrendsUsecase: loadTrendsUsecase,
      now: now,
    ).execute();
  }
}
