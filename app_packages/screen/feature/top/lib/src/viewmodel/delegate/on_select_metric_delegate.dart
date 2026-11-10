import 'package:domain_exercise_history/domain_exercise_history.dart';
import 'package:meta/meta.dart';
import 'package:state_stream/state_stream.dart';
import 'package:usecase_save_top_screen_metric/usecase_save_top_screen_metric.dart';

import '../state/top_screen_state.dart';

/// 選んだ指標を保存し、表示中の合計は振り分け直さない。
///
/// Example:
/// ```dart
/// delegate.execute(PeriodTotalMetric.distance);
/// ```
@internal
final class OnSelectMetricDelegate {
  /// [state] と [saveTopScreenMetricUsecase] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnSelectMetricDelegate(
  ///   state: state,
  ///   saveTopScreenMetricUsecase: saveTopScreenMetricUsecase,
  /// );
  /// ```
  const OnSelectMetricDelegate({
    required this.state,
    required this.saveTopScreenMetricUsecase,
  });

  /// 更新する画面状態。
  final MutableStateStream<TopScreenState> state;

  /// 指標の保存。
  final SaveTopScreenMetricUsecase saveTopScreenMetricUsecase;

  /// [metric] を保存できたときだけ State の指標を変える。
  ///
  /// まだ読み込んでいないとき、または保存が失敗したときは State を変えない。
  /// アドバイス本文とトーンは変更しない。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(PeriodTotalMetric.distance);
  /// ```
  Future<void> execute(PeriodTotalMetric metric) async {
    await state.updateWithLock((current, emitter) async {
      if (!current.loaded) {
        return;
      }
      await saveTopScreenMetricUsecase.execute(
        SaveTopScreenMetricRequest(metric: metric),
      );
      await emitter.emit(
        TopScreenState(
          loaded: true,
          metric: metric,
          today: current.today,
          week: current.week,
          month: current.month,
          goal: current.goal,
          adviceText: current.adviceText,
          adviceTone: current.adviceTone,
          pendingModelDownloadGuidance: current.pendingModelDownloadGuidance,
        ),
      );
    });
  }
}
