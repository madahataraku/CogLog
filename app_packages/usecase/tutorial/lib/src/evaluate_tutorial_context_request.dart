import 'tutorial_kind.dart';

/// 文脈チュートリアル表示要否の依頼。
///
/// Example:
/// ```dart
/// const EvaluateTutorialContextRequest(kind: TutorialKind.camera);
/// ```
final class EvaluateTutorialContextRequest {
  /// [kind] は goalSettings / camera / meterEdit / trends / history。
  ///
  /// Example:
  /// ```dart
  /// const EvaluateTutorialContextRequest(kind: TutorialKind.goalSettings);
  /// ```
  const EvaluateTutorialContextRequest({required this.kind});

  /// 判定する文脈。main は呼び出さない。
  final TutorialKind kind;
}
