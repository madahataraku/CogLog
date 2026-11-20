import 'package:meta/meta.dart';
import 'package:screen_navigation/screen_navigation.dart';

/// データ管理画面を開く。
///
/// Example:
/// ```dart
/// OnOpenDataManagementDelegate(navigation: navigation).execute();
/// ```
@internal
final class OnOpenDataManagementDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnOpenDataManagementDelegate(navigation: navigation);
  /// ```
  const OnOpenDataManagementDelegate({required this.navigation});

  /// 画面遷移。
  final ScreenNavigation navigation;

  /// データ管理を積む。
  ///
  /// Example:
  /// ```dart
  /// OnOpenDataManagementDelegate(navigation: navigation).execute();
  /// ```
  void execute() {
    navigation.openDataManagement();
  }
}
