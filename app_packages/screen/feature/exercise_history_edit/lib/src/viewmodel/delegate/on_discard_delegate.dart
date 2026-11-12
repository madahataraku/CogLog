import 'package:screen_navigation/screen_navigation.dart';

/// 未保存変更を捨てて編集画面を閉じる。
///
/// Example:
/// ```dart
/// OnDiscardDelegate(navigation: navigation).execute();
/// ```
final class OnDiscardDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnDiscardDelegate(navigation: navigation);
  /// ```
  const OnDiscardDelegate({required this.navigation});

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// 結果なしで 1 つ戻る。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute();
  /// ```
  void execute() {
    navigation.pop();
  }
}
