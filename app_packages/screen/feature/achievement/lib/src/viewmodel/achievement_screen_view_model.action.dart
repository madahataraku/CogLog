part of 'achievement_screen_view_model.dart';

/// アチーブメント画面の操作。
@internal
extension AchievementScreenViewModelActions on AchievementScreenViewModel {
  /// 一覧を初回読込する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onInitialize();
  /// ```
  Future<void> onInitialize() {
    return OnInitializeDelegate(
      state: state,
      loadUsecase: loadUsecase,
      markViewed: markViewed,
      now: now(),
    ).execute();
  }

  /// 失敗時に一覧を再読込する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onRetry();
  /// ```
  Future<void> onRetry() {
    return OnRetryDelegate(
      state: state,
      loadUsecase: loadUsecase,
      markViewed: markViewed,
      now: now(),
    ).execute();
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
