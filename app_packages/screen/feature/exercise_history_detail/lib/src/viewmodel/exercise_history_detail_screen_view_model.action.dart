part of 'exercise_history_detail_screen_view_model.dart';

/// 運動履歴詳細の操作。
@internal
extension ExerciseHistoryDetailScreenViewModelActions
    on ExerciseHistoryDetailScreenViewModel {
  /// [id] の詳細と同一日列を読み込む。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onInitialize(id: 'id');
  /// ```
  Future<void> onInitialize({required String id}) {
    final delegate = OnInitializeDelegate(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
      loadSameDayUsecase: loadSameDayUsecase,
    );
    return delegate.execute(id: id);
  }

  /// 同一日の [index] へページをめくる。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onPageChanged(index: 1);
  /// ```
  Future<void> onPageChanged({required int index}) {
    final delegate = OnPageChangedDelegate(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
    );
    return delegate.execute(index: index);
  }

  /// 読込失敗を再試行する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onRetry();
  /// ```
  Future<void> onRetry() {
    final delegate = OnRetryDelegate(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
    );
    return delegate.execute();
  }

  /// 1 つ戻る。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onBack();
  /// ```
  void onBack() {
    OnBackDelegate(navigation: navigation).execute();
  }
}
