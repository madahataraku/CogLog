import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';

import '../state/trends_screen_state.dart';
import 'on_reload_delegate.dart';

/// 期間選択を State へ反映し、系列を読み直す。
///
/// Example:
/// ```dart
/// OnSelectPeriodDelegate(
///   state: state,
///   loadTrendsUsecase: loadTrendsUsecase,
///   now: DateTime(2026, 11, 10),
/// ).execute(TrendsPeriod.days90);
/// ```
final class OnSelectPeriodDelegate {
  /// [state]・読込 Usecase・基準時刻を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectPeriodDelegate(
  ///   state: state,
  ///   loadTrendsUsecase: loadTrendsUsecase,
  ///   now: DateTime(2026, 11, 10),
  /// );
  /// ```
  const OnSelectPeriodDelegate({
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

  /// [period] が現在と違うときだけ置き換え、その後読み直す。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(TrendsPeriod.days90);
  /// ```
  Future<void> execute(TrendsPeriod period) async {
    final changed = await state.updateWithLock((current, emitter) async {
      if (current.period == period) {
        return false;
      }
      await emitter.emit(current.copyWith(period: period));
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
