import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';

import '../state/trends_comparison.dart';
import '../state/trends_screen_state.dart';

/// 比較プリセットを State へ反映する（再取得しない）。
///
/// Example:
/// ```dart
/// OnSelectComparisonDelegate(state: state)
///     .execute(TrendsComparison.durationDistance);
/// ```
@internal
final class OnSelectComparisonDelegate {
  /// [state] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectComparisonDelegate(state: state);
  /// ```
  const OnSelectComparisonDelegate({required this.state});

  /// 更新する画面状態。
  final MutableStateStream<TrendsScreenState> state;

  /// [comparison] が違うときだけ置き換える。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsComparison.caloriesBodyFat);
  /// ```
  Future<void> execute(TrendsComparison comparison) async {
    await state.updateWithLock((current, emitter) async {
      if (current.comparison == comparison) {
        return;
      }
      await emitter.emit(current.copyWith(comparison: comparison));
    });
  }
}
