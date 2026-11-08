import 'package:screen_navigation/screen_navigation.dart';

/// 一覧項目から詳細へ遷移する。
///
/// Example:
/// ```dart
/// OnTapItemDelegate(navigation: navigation).execute(id: 'id');
/// ```
final class OnTapItemDelegate {
  /// [navigation] を受け取る。
  ///
  /// Example:
  /// ```dart
  /// OnTapItemDelegate(navigation: navigation);
  /// ```
  const OnTapItemDelegate({required this.navigation});

  /// 画面遷移の窓口。
  final ScreenNavigation navigation;

  /// 詳細をスタックへ積む。
  ///
  /// Example:
  /// ```dart
  /// delegate.execute(id: 'id');
  /// ```
  void execute({required String id}) {
    navigation.openExerciseHistoryDetail(id: id);
  }
}
