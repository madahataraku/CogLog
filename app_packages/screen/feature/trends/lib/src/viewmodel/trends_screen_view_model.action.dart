part of 'trends_screen_view_model.dart';

/// 推移画面の操作。
@internal
extension TrendsScreenViewModelActions on TrendsScreenViewModel {
  /// 画面表示時に系列を読み込む。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onInitialize();
  /// ```
  Future<void> onInitialize({DateTime? now}) {
    return OnInitializeDelegate(
      state: state,
      loadTrendsUsecase: loadTrendsUsecase,
      now: now ?? DateTime.now(),
    ).execute();
  }

  /// 期間を選び、系列を読み直す。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectPeriod(TrendsPeriod.days90);
  /// ```
  Future<void> onSelectPeriod(TrendsPeriod period, {DateTime? now}) {
    return OnSelectPeriodDelegate(
      state: state,
      loadTrendsUsecase: loadTrendsUsecase,
      now: now ?? DateTime.now(),
    ).execute(period);
  }

  /// 比較プリセットを選ぶ（再取得しない）。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onSelectComparison(TrendsComparison.durationDistance);
  /// ```
  Future<void> onSelectComparison(TrendsComparison comparison) {
    return OnSelectComparisonDelegate(state: state).execute(comparison);
  }

  /// ヘルス許可をリクエストし、系列を読み直す。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onRequestHealthPermission();
  /// ```
  Future<void> onRequestHealthPermission({DateTime? now}) {
    return OnRequestHealthPermissionDelegate(
      state: state,
      requestHealthPermissionUsecase: requestHealthPermissionUsecase,
      loadTrendsUsecase: loadTrendsUsecase,
      now: now ?? DateTime.now(),
    ).execute();
  }

  /// OS のアプリ設定を開く。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onOpenAppSettings();
  /// ```
  Future<void> onOpenAppSettings() {
    return OnOpenAppSettingsDelegate(
      openAppSettingsUsecase: openAppSettingsUsecase,
    ).execute();
  }

  /// 系列の読取を再試行する。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onRetry();
  /// ```
  Future<void> onRetry({DateTime? now}) {
    return OnReloadDelegate(
      state: state,
      loadTrendsUsecase: loadTrendsUsecase,
      now: now ?? DateTime.now(),
    ).execute();
  }
}
