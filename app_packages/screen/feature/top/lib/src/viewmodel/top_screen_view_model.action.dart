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
    required ConditionalAdviceCatalog conditionalCatalog,
    required Map<ConditionalAdviceMetric, String> metricLabels,
  }) {
    final delegate = OnInitializeDelegate(
      state: state,
      loadTopScreenUsecase: loadTopScreenUsecase,
      generateTopAdviceUsecase: generateTopAdviceUsecase,
      evaluateOnDeviceLlmGuidanceUsecase: evaluateOnDeviceLlmGuidanceUsecase,
      evaluateGemmaMeterGuidanceUsecase: evaluateGemmaMeterGuidanceUsecase,
      guidanceSession: guidanceSession,
      gemmaSession: gemmaSession,
    );
    return delegate.execute(
      locale: locale,
      noExercise: noExercise,
      fallbackTemplates: fallbackTemplates,
      conditionalCatalog: conditionalCatalog,
      metricLabels: metricLabels,
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

  /// (A) 誘導予約を消費し、同一プロセスでの再表示を止める。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onAcknowledgeModelDownloadGuidance();
  /// ```
  Future<void> onAcknowledgeModelDownloadGuidance() {
    return OnAcknowledgeModelDownloadGuidanceDelegate(
      state: state,
      session: guidanceSession,
    ).execute();
  }

  /// OS LLM モデル準備を依頼する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onPrepareModelDownloadGuidance();
  /// ```
  Future<void> onPrepareModelDownloadGuidance() {
    return OnPrepareModelDownloadGuidanceDelegate(
      prepareOnDeviceLlmModelUsecase: prepareOnDeviceLlmModelUsecase,
    ).execute();
  }

  /// (A) ダイアログ完了後に (B) の要否を判定する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onEvaluateGemmaMeterGuidance();
  /// ```
  Future<void> onEvaluateGemmaMeterGuidance() {
    return OnEvaluateGemmaMeterGuidanceDelegate(
      state: state,
      evaluateGemmaMeterGuidanceUsecase: evaluateGemmaMeterGuidanceUsecase,
      gemmaSession: gemmaSession,
    ).execute();
  }

  /// (B) 誘導予約を消費し、同一プロセスでの再表示を止める。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onAcknowledgeGemmaMeterGuidance();
  /// ```
  Future<void> onAcknowledgeGemmaMeterGuidance() {
    return OnAcknowledgeGemmaMeterGuidanceDelegate(
      state: state,
      session: gemmaSession,
    ).execute();
  }

  /// Gemma モデル準備の進捗を流す。
  ///
  /// Example:
  /// ```dart
  /// await for (final progress in viewModel.onPrepareGemmaMeterGuidance()) {
  ///   progress;
  /// }
  /// ```
  Stream<double> onPrepareGemmaMeterGuidance() {
    return OnPrepareGemmaMeterGuidanceDelegate(
      prepareGemmaMeterModelUsecase: prepareGemmaMeterModelUsecase,
    ).execute();
  }

  /// アチーブメント画面を開く。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onOpenAchievements();
  /// ```
  Future<void> onOpenAchievements() {
    return OnOpenAchievementsDelegate(
      navigation: navigation,
      state: state,
      newIndicator: newIndicator,
      now: now,
    ).execute();
  }

  /// アプリ設定を開く。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onOpenAppSettings();
  /// ```
  void onOpenAppSettings() {
    OnOpenAppSettingsDelegate(navigation: navigation).execute();
  }
}
