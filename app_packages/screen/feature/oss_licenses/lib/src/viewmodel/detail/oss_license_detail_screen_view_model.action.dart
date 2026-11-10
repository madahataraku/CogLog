part of 'oss_license_detail_screen_view_model.dart';

/// OSS ライセンス詳細の操作。
@internal
extension OssLicenseDetailScreenViewModelActions
    on OssLicenseDetailScreenViewModel {
  /// [packageName] の本文を読み込む。
  ///
  /// Example:
  /// ```dart
  /// await viewModel.onInitialize(packageName: 'riverpod');
  /// ```
  Future<void> onInitialize({required String packageName}) {
    return OnInitializeDelegate(
      state: state,
      loadUsecase: loadUsecase,
    ).execute(packageName: packageName);
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
