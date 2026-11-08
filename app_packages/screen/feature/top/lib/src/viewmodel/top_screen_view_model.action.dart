part of 'top_screen_view_model.dart';

/// トップ画面の操作。
@internal
extension TopScreenViewModelActions on TopScreenViewModel {
  /// 現在時刻で期間合計を読み、アドバイス本文とトーンを再生成する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onInitialize(
  ///   locale: 'ja',
  ///   noExercise: AdviceTemplate(
  ///     text: '今日はまだ運動していません',
  ///     tone: AdviceTone.realized,
  ///   ),
  ///   fallbackTemplates: const [
  ///     AdviceTemplate(text: 'a', tone: AdviceTone.fun),
  ///   ],
  /// );
  /// ```
  Future<void> onInitialize({
    required String locale,
    required AdviceTemplate noExercise,
    required List<AdviceTemplate> fallbackTemplates,
  }) {
    final delegate = OnInitializeDelegate(
      state: state,
      loadTopScreenUsecase: loadTopScreenUsecase,
      generateTopAdviceUsecase: generateTopAdviceUsecase,
    );
    return delegate.execute(
      locale: locale,
      noExercise: noExercise,
      fallbackTemplates: fallbackTemplates,
    );
  }

  /// [metric] を保存し、表示中の合計は振り分け直さない。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectMetric(PeriodTotalMetric.distance);
  /// ```
  Future<void> onSelectMetric(PeriodTotalMetric metric) {
    final delegate = OnSelectMetricDelegate(
      state: state,
      saveTopScreenMetricUsecase: saveTopScreenMetricUsecase,
    );
    return delegate.execute(metric);
  }
}
