import 'package:riverpod/riverpod.dart';

/// 画面遷移の窓口。
///
/// タブ切替は go_router の StatefulShellRoute が担う。
/// スタック型の子画面遷移はここ経由で行う。
///
/// Example:
/// ```dart
/// screenNavigationProvider;
/// ```
abstract interface class ScreenNavigation {
  /// 運動履歴詳細をスタックへ積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openExerciseHistoryDetail(
  ///   id: '11111111-1111-4111-8111-111111111111',
  /// );
  /// ```
  void openExerciseHistoryDetail({required String id});

  /// 現在のスタックを 1 つ戻す。
  ///
  /// Example:
  /// ```dart
  /// navigation.pop();
  /// ```
  void pop();

  /// ホームタブの初期位置へ切り替える。
  ///
  /// Example:
  /// ```dart
  /// navigation.goToHomeTab();
  /// ```
  void goToHomeTab();
}

/// 画面遷移の注入点。未接続のときは失敗する。
///
/// Example:
/// ```dart
/// screenNavigationProvider;
/// ```
final screenNavigationProvider = Provider<ScreenNavigation>(
  (ref) => throw UnimplementedError('screenNavigationProvider'),
);
