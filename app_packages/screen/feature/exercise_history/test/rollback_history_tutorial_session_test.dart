import 'package:flutter_test/flutter_test.dart';
import 'package:screen_feature_exercise_history/src/viewmodel/rollback_history_tutorial_session.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';

void main() {
  // テスト対象:
  // rollbackHistoryTutorialSession
  //
  // テスト内容:
  // history 所有中なら activeKind と提示済みを戻す。
  test('history 所有中は activeKind と提示済みを戻す', () {
    final session = TutorialRuntimeSession()
      ..activeKind = TutorialKind.history
      ..markContextPresented(TutorialKind.history);

    rollbackHistoryTutorialSession(session);

    expect(session.activeKind, isNull);
    expect(
      session.hasContextPresentedThisProcess(TutorialKind.history),
      isFalse,
    );
  });

  // テスト対象:
  // rollbackHistoryTutorialSession
  //
  // テスト内容:
  // 他文脈が active のとき clearActive せず、history の提示済みだけ戻す。
  test('他文脈表示中は activeKind を残し history 提示済みだけ戻す', () {
    final session = TutorialRuntimeSession()
      ..activeKind = TutorialKind.camera
      ..markContextPresented(TutorialKind.history)
      ..markContextPresented(TutorialKind.camera);

    rollbackHistoryTutorialSession(session);

    expect(session.activeKind, TutorialKind.camera);
    expect(
      session.hasContextPresentedThisProcess(TutorialKind.history),
      isFalse,
    );
    expect(session.hasContextPresentedThisProcess(TutorialKind.camera), isTrue);
  });
}
