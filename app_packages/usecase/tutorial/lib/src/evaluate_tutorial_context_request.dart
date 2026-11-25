import 'tutorial_kind.dart';

/// 文脈チュートリアル表示要否の依頼。
///
/// Example:
/// ```dart
/// const EvaluateTutorialContextRequest(kind: TutorialKind.camera);
/// ```
final class EvaluateTutorialContextRequest {
  /// [kind] は camera / meterEdit / trends / history / achievement。
  /// achievement のとき [unlockedAchievementCount] が必須。
  ///
  /// Example:
  /// ```dart
  /// const EvaluateTutorialContextRequest(
  ///   kind: TutorialKind.achievement,
  ///   unlockedAchievementCount: 1,
  /// );
  /// ```
  const EvaluateTutorialContextRequest({
    required this.kind,
    this.unlockedAchievementCount,
  });

  /// 判定する文脈。main は呼び出さない。
  final TutorialKind kind;

  /// achievement のみ必須。獲得件数。
  final int? unlockedAchievementCount;
}
