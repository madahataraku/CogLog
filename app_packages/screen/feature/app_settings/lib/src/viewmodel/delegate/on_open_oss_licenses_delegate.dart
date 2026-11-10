import 'package:screen_navigation/screen_navigation.dart';

/// OSS ライセンス一覧を開く。
///
/// Example:
/// ```dart
/// OnOpenOssLicensesDelegate(navigation: navigation).execute();
/// ```
final class OnOpenOssLicensesDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenOssLicensesDelegate(navigation: navigation);
  /// ```
  const OnOpenOssLicensesDelegate({required this.navigation});

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// OSS ライセンスへ遷移する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  void execute() {
    navigation.openOssLicenses();
  }
}
