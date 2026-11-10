part of 'oss_licenses_screen_view_model.dart';

/// OSS ライセンス一覧の操作。
@internal
extension OssLicensesScreenViewModelActions on OssLicensesScreenViewModel {
  /// 一覧を読み込む。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onInitialize();
  /// ```
  Future<void> onInitialize() {
    return OnInitializeDelegate(
      state: state,
      loadUsecase: loadUsecase,
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

  /// 詳細を開く。
  ///
  /// Example:
  /// ```dart
  /// viewModel.onOpenDetail(packageName: 'riverpod');
  /// ```
  void onOpenDetail({required String packageName}) {
    OnOpenDetailDelegate(navigation: navigation)
        .execute(packageName: packageName);
  }
}
