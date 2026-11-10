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
  /// 開始時に [TrendsScreenState.reloadGeneration] を進め、成功・失敗のどちらでも
  /// 自世代以外の結果は捨てる（同一 period/group の重なり読込対策）。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  Future<void> execute() async {
    final started = await state.updateWithLock((current, emitter) async {
      final generation = current.reloadGeneration + 1;
      await emitter.emit(
        current.copyWith(loading: true, reloadGeneration: generation),
      );
      return (snapshot: current, generation: generation);
    });
    try {
      final result = await loadTrendsUsecase.execute(
        LoadTrendsRequest(
          now: now,
          period: mapTrendsPeriod(started.snapshot.period),
          groupIsBody: started.snapshot.group == TrendsMetricGroup.body,
        ),
      );
      await state.updateWithLock((current, emitter) async {
        if (!_isCurrent(current, started)) {
          return;
        }
        await emitter.emit(
          current.copyWith(
            loading: false,
            bodyReadFailed: result.bodyReadFailed,
            bodyHistoryLimited: result.bodyHistoryLimited,
            healthPermissionUi: mapTrendsHealthUi(result.healthPermission),
            buckets: result.buckets,
            exerciseSeries: mapTrendsSeries(result.exerciseSeries),
            bodySeries: mapTrendsSeries(result.bodySeries),
          ),
        );
      });
    } catch (_) {
      await state.updateWithLock((current, emitter) async {
        if (!_isCurrent(current, started)) {
          return;
        }
        await emitter.emit(
          current.copyWith(
            loading: false,
            bodyReadFailed: true,
            bodyHistoryLimited: false,
            buckets: const [],
            exerciseSeries: const {},
            bodySeries: const {},
          ),
        );
      });
    }
  }

  /// 自世代かつ開始時と同じ期間・グループなら最新の読込結果とみなす。
  ///
  /// Example:
  /// ```dart
  /// _isCurrent(current, started);
  /// ```
  bool _isCurrent(
    TrendsScreenState current,
    ({TrendsScreenState snapshot, int generation}) started,
  ) =>
      current.reloadGeneration == started.generation &&
      current.period == started.snapshot.period &&
      current.group == started.snapshot.group;
}
