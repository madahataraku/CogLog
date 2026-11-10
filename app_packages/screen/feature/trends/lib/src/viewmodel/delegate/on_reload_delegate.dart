import 'package:state_stream/state_stream.dart';
import 'package:usecase_load_trends/usecase_load_trends.dart';

import '../state/trends_screen_state.dart';
import 'map_trends_health_ui.dart';
import 'map_trends_period.dart';
import 'map_trends_series.dart';

/// 現在の期間・グループで系列を読み直す。
///
/// Example:
/// ```dart
/// OnReloadDelegate(
///   state: state,
///   loadTrendsUsecase: loadTrendsUsecase,
///   now: DateTime(2026, 11, 10),
/// ).execute();
/// ```
final class OnReloadDelegate {
  /// [state]・読込 Usecase・基準時刻を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnReloadDelegate(
  ///   state: state,
  ///   loadTrendsUsecase: loadTrendsUsecase,
  ///   now: DateTime(2026, 11, 10),
  /// );
  /// ```
  const OnReloadDelegate({
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

  /// 読込中にしてから系列を取り、結果を State へ書く。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    final snapshot = await state.updateWithLock((current, emitter) async {
      await emitter.emit(current.copyWith(loading: true));
      return current;
    });
    final result = await loadTrendsUsecase.execute(
      LoadTrendsRequest(
        now: now,
        period: mapTrendsPeriod(snapshot.period),
        groupIsBody: snapshot.group == TrendsMetricGroup.body,
      ),
    );
    await state.updateWithLock((current, emitter) async {
      await emitter.emit(
        current.copyWith(
          loading: false,
          bodyReadFailed: result.bodyReadFailed,
          healthPermissionUi: mapTrendsHealthUi(result.healthPermission),
          buckets: result.buckets,
          exerciseSeries: mapTrendsSeries(result.exerciseSeries),
          bodySeries: mapTrendsSeries(result.bodySeries),
        ),
      );
    });
  }
}
