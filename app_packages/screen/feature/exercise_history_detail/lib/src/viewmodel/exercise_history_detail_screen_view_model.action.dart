part of 'exercise_history_detail_screen_view_model.dart';

/// 運動履歴詳細の操作。
@internal
extension ExerciseHistoryDetailScreenViewModelActions
    on ExerciseHistoryDetailScreenViewModel {
  /// [id] の詳細を読み込む。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onInitialize(id: 'id');
  /// ```
  Future<void> onInitialize({required String id}) {
    final delegate = OnInitializeDelegate(
      state: state,
      loadDetailUsecase: loadDetailUsecase,
    );
    return delegate.execute(id: id);
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
