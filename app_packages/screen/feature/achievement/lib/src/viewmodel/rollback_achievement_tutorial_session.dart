import 'package:usecase_tutorial/usecase_tutorial.dart';

/// アチーブメント文脈の session 提示済み／表示中だけを戻す。
///
/// Example:
/// ```dart
/// rollbackAchievementTutorialSession(session);
/// ```
void rollbackAchievementTutorialSession(TutorialRuntimeSession session) {
  if (session.activeKind == TutorialKind.achievement) {
    session.clearActive();
  }
  session.clearContextPresented(TutorialKind.achievement);
}
