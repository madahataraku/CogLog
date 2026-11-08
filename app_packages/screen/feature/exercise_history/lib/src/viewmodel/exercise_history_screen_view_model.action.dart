part of 'exercise_history_screen_view_model.dart';

/// 運動履歴一覧の操作。
@internal
extension ExerciseHistoryScreenViewModelActions
    on ExerciseHistoryScreenViewModel {
  /// 現地当月の先頭頁を読み込む。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onInitialize();
  /// ```
  Future<void> onInitialize() {
    final delegate = OnInitializeDelegate(
      state: state,
      loadPageUsecase: loadPageUsecase,
      now: clock(),
    );
    return delegate.execute();
  }

  /// 月を切り替えて先頭から読み直す。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectMonth(year: 2026, month: 10);
  /// ```
  Future<void> onSelectMonth({required int year, required int month}) {
    final delegate = OnSelectMonthDelegate(
      state: state,
      loadPageUsecase: loadPageUsecase,
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

  /// 続きの頁を読む。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onLoadMore();
  /// ```
  Future<void> onLoadMore() {
    final delegate = OnLoadMoreDelegate(
      state: state,
      loadPageUsecase: loadPageUsecase,
    );
    return delegate.execute();
  }

  /// Pull to refresh で先頭から読み直す。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onRefresh();
  /// ```
  Future<void> onRefresh() {
    final delegate = OnRefreshDelegate(
      state: state,
      loadPageUsecase: loadPageUsecase,
    );
    return delegate.execute();
  }

  /// 失敗した読込を再試行する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onRetry();
  /// ```
  Future<void> onRetry() {
    final delegate = OnRetryDelegate(
      state: state,
      loadPageUsecase: loadPageUsecase,
    );
    return delegate.execute();
  }

  /// 詳細へ遷移する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onTapItem(id: 'id');
  /// ```
  void onTapItem({required String id}) {
    OnTapItemDelegate(navigation: navigation).execute(id: id);
  }
}
