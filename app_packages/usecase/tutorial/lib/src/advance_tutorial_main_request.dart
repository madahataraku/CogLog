part 'advance_tutorial_main_goal_saved_request.dart';
part 'advance_tutorial_main_next_request.dart';
part 'advance_tutorial_main_start_request.dart';

/// メイン導線の進行依頼。
///
/// Example:
/// ```dart
/// const AdvanceTutorialMainRequest.start();
/// ```
sealed class AdvanceTutorialMainRequest {
  /// 依頼の基底。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainRequest.next();
  /// ```
  const AdvanceTutorialMainRequest();

  /// 段階1開始（自動または手動再表示）。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainRequest.start();
  /// ```
  const factory AdvanceTutorialMainRequest.start() =
      AdvanceTutorialMainStartRequest;

  /// 主ボタン（次へ／閉じる）。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainRequest.next();
  /// ```
  const factory AdvanceTutorialMainRequest.next() =
      AdvanceTutorialMainNextRequest;

  /// 段階3で目標保存が成功したとき。
  ///
  /// Example:
  /// ```dart
  /// const AdvanceTutorialMainRequest.goalSaved();
  /// ```
  const factory AdvanceTutorialMainRequest.goalSaved() =
      AdvanceTutorialMainGoalSavedRequest;
}
