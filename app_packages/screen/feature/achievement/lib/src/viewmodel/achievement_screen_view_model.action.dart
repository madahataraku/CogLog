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

  /// アチーブメント文脈の表示要否を評価する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onEvaluateTutorial();
  /// ```
  Future<void> onEvaluateTutorial() {
    return OnEvaluateTutorialDelegate(
      state: state,
      evaluateContext: evaluateTutorial,
      session: tutorialSession,
    ).execute();
  }

  /// アチーブメント文脈の表示予約を消費する。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onAcknowledgeTutorial();
  /// ```
  Future<void> onAcknowledgeTutorial() {
    return OnAcknowledgeTutorialDelegate(state: state).execute();
  }

  /// アチーブメント文脈を閉じ、表示済みにする。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onDismissTutorial();
  /// ```
  Future<void> onDismissTutorial() {
    return OnDismissTutorialDelegate(
      state: state,
      markSeen: markTutorialSeen,
    ).execute();
  }
}
