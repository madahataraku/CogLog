import 'package:riverpod/riverpod.dart';

import 'exercise_history_edit_pop_result.dart';

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

  /// 運動履歴編集画面を積み、閉じるまで待つ。
  ///
  /// 破棄・システム戻りのときは null。保存成功時は [ExerciseHistoryEditPopResult]。
  ///
  /// Example:
  /// ```dart
  /// final result = await navigation.openExerciseHistoryEditAndWait(
  ///   id: '11111111-1111-4111-8111-111111111111',
  /// );
  /// ```
  Future<ExerciseHistoryEditPopResult?> openExerciseHistoryEditAndWait({
    required String id,
  });

  /// アプリ設定をホームタブのスタックへ積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openAppSettings();
  /// ```
  void openAppSettings();

  /// アチーブメント画面をホームタブのスタックへ積み、閉じるまで待つ。
  ///
  /// Example:
  /// ```dart
  /// await navigation.openAchievements();
  /// ```
  Future<void> openAchievements();

  /// デバッグ画面をアプリ設定の子として積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openDebug();
  /// ```
  void openDebug();

  /// 通知設定画面をアプリ設定の子として積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openNotificationSettings();
  /// ```
  void openNotificationSettings();

  /// OSS ライセンス一覧をアプリ設定の子として積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openOssLicenses();
  /// ```
  void openOssLicenses();

  /// OSS ライセンス詳細を一覧の子として積む。
  ///
  /// Example:
  /// ```dart
  /// navigation.openOssLicenseDetail(packageName: 'riverpod');
  /// ```
  void openOssLicenseDetail({required String packageName});

  /// 現在のスタックを 1 つ戻す。
  ///
  /// Example:
  /// ```dart
  /// navigation.pop();
  /// ```
  void pop();

  /// 現在のスタックを [result] 付きで 1 つ戻す。
  ///
  /// Example:
  /// ```dart
  /// navigation.popWithResult(
  ///   const ExerciseHistoryEditPopResult(
  ///     saved: true,
  ///     recordedLocalDayChanged: false,
  ///   ),
  /// );
  /// ```
  void popWithResult<T extends Object?>(T result);

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
