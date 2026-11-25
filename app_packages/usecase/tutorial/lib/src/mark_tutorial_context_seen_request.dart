import 'tutorial_kind.dart';

/// 文脈を表示済みにする依頼。
///
/// Example:
/// ```dart
/// const MarkTutorialContextSeenRequest(kind: TutorialKind.camera);
/// ```
final class MarkTutorialContextSeenRequest {
  /// [kind] は main 以外。
  ///
  /// Example:
  /// ```dart
  /// const MarkTutorialContextSeenRequest(kind: TutorialKind.history);
  /// ```
  const MarkTutorialContextSeenRequest({required this.kind});

  /// 閉じた文脈。
  final TutorialKind kind;
}
