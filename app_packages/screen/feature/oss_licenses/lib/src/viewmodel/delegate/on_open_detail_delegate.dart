import 'package:screen_navigation/screen_navigation.dart';

/// ライセンス詳細を開く。
///
/// Example:
/// ```dart
/// OnOpenDetailDelegate(navigation: navigation).execute(
///   packageName: 'riverpod',
/// );
/// ```
final class OnOpenDetailDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenDetailDelegate(navigation: navigation);
  /// ```
  const OnOpenDetailDelegate({required this.navigation});

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// 詳細へ遷移する。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(packageName: 'riverpod');
  /// ```
  void execute({required String packageName}) {
    navigation.openOssLicenseDetail(packageName: packageName);
  }
}
