part of 'exercise_history_screen_view_model.dart';

/// 運動履歴カレンダーの操作。
@internal
extension ExerciseHistoryScreenViewModelActions
    on ExerciseHistoryScreenViewModel {
  /// 初回表示で現地当月を読む。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onColdStart();
  /// ```
  Future<void> onColdStart() {
    final delegate = OnColdStartDelegate(
      state: state,
      loadMonthUsecase: loadMonthUsecase,
      now: clock(),
    );
    return delegate.execute();
  }

  /// 選択中の月を年月そのまま再取得する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onReloadSelectedMonth();
  /// ```
  Future<void> onReloadSelectedMonth() {
    final delegate = OnReloadSelectedMonthDelegate(
      state: state,
      loadMonthUsecase: loadMonthUsecase,
    );
    return delegate.execute();
  }

  /// 月を切り替えて読み直す。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectMonth(year: 2026, month: 10);
  /// ```
  Future<void> onSelectMonth({required int year, required int month}) {
    final delegate = OnSelectMonthDelegate(
      state: state,
      loadMonthUsecase: loadMonthUsecase,
    );
    return delegate.execute(year: year, month: month);
  }

  /// 前月へ移る。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectPreviousMonth();
  /// ```
  Future<void> onSelectPreviousMonth() {
    final current = state.state;
    if (current.month == 1) {
      return onSelectMonth(year: current.year - 1, month: 12);
    }
    return onSelectMonth(year: current.year, month: current.month - 1);
  }

  /// 次月へ移る。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectNextMonth();
  /// ```
  Future<void> onSelectNextMonth() {
    final current = state.state;
    if (current.month == 12) {
      return onSelectMonth(year: current.year + 1, month: 1);
    }
    return onSelectMonth(year: current.year, month: current.month + 1);
  }

  /// 失敗した月読込を再試行する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onRetry();
  /// ```
  Future<void> onRetry() {
    final delegate = OnRetryDelegate(
      state: state,
      loadMonthUsecase: loadMonthUsecase,
    );
    return delegate.execute();
  }

  /// スタンプ日の先頭詳細へ遷移する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onTapDay(day: 5);
  /// ```
  void onTapDay({required int day}) {
    OnTapDayDelegate(state: state, navigation: navigation).execute(day: day);
  }

  /// 運動履歴文脈コーチマークの要否を評価する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onEvaluateTutorial();
  /// ```
  Future<void> onEvaluateTutorial() {
    return OnEvaluateTutorialDelegate(
      state: state,
      evaluateContext: evaluateTutorialContextUsecase,
      session: tutorialSession,
    ).execute();
  }

  /// 運動履歴文脈の表示予約を消費する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onAcknowledgeTutorial();
  /// ```
  Future<void> onAcknowledgeTutorial() {
    return OnAcknowledgeTutorialDelegate(state: state).execute();
  }

  /// 運動履歴文脈を閉じ、表示済みにする。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onDismissTutorial();
  /// ```
  Future<void> onDismissTutorial() {
    return OnDismissTutorialDelegate(
      state: state,
      markSeen: markTutorialContextSeenUsecase,
    ).execute();
  }
}
