import 'package:meta/meta.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

/// 運動履歴文脈を所有しているときだけ [session] の表示中を消し、提示済みも戻す。
///
/// 他文脈がすでに [TutorialRuntimeSession.activeKind] を取っている場合は
/// `clearActive` しない（古い show 完了が新しい文脈を消さない）。
///
/// Example:
/// ```dart
/// rollbackHistoryTutorialSession(session);
/// ```
@internal
void rollbackHistoryTutorialSession(TutorialRuntimeSession session) {
  if (session.activeKind == TutorialKind.history) {
    session.clearActive();
  }
  session.clearContextPresented(TutorialKind.history);
}
