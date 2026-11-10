import 'package:state_stream/state_stream.dart';

import '../state/trends_screen_state.dart';

/// 期間選択を State へ反映する。
///
/// Example:
/// ```dart
/// OnSelectPeriodDelegate(state: state).execute(TrendsPeriod.days90);
/// ```
final class OnSelectPeriodDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectPeriodDelegate(state: state);
  /// ```
  const OnSelectPeriodDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// [period] が現在と違うときだけ置き換える。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsPeriod.days90);
  /// ```
  Future<void> execute(TrendsPeriod period) async {
    await state.updateWithLock((current, emitter) async {
      if (current.period == period) {
        return;
      }
      await emitter.emit(
        TrendsScreenState(period: period, group: current.group),
      );
    });
  }
}
