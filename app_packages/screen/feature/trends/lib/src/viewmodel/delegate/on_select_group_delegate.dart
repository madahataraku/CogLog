import 'package:state_stream/state_stream.dart';

import '../state/trends_screen_state.dart';

/// 指標グループ選択を State へ反映する。
///
/// Example:
/// ```dart
/// OnSelectGroupDelegate(state: state).execute(TrendsMetricGroup.body);
/// ```
final class OnSelectGroupDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectGroupDelegate(state: state);
  /// ```
  const OnSelectGroupDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// [group] が現在と違うときだけ置き換える。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsMetricGroup.body);
  /// ```
  Future<void> execute(TrendsMetricGroup group) async {
    await state.updateWithLock((current, emitter) async {
      if (current.group == group) {
        return;
      }
      await emitter.emit(
        TrendsScreenState(period: current.period, group: group),
      );
    });
  }
}
