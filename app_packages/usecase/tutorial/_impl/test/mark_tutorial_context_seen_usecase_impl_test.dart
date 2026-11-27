import 'package:data_repository_tutorial_testing/data_repository_tutorial_testing.dart';
import 'package:test/test.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:usecase_tutorial_impl/usecase_tutorial_impl.dart';

void main() {
  // テスト対象:
  // MarkTutorialContextSeenUsecaseImpl.execute
  //
  // テスト内容:
  // camera を永続 seen にし、session の表示中を消す。
  test('camera を seen にし session を clear', () async {
    final repository = MemoryTutorialRepository();
    final session = TutorialRuntimeSession()
      ..activeKind = TutorialKind.camera
      ..markContextPresented(TutorialKind.camera);
    final usecase = MarkTutorialContextSeenUsecaseImpl(
      repository: repository,
      session: session,
    );
    await usecase.execute(
      const MarkTutorialContextSeenRequest(kind: TutorialKind.camera),
    );
    expect(
      (await repository.read()).cameraContextSeen,
      isTrue,
      reason: 'cameraContextSeen が true になること',
    );
    expect(session.isShowing, isFalse, reason: 'session が非表示になること');
  });

  test('achievement を seen にし session を clear', () async {
    final repository = MemoryTutorialRepository();
    final session = TutorialRuntimeSession()
      ..activeKind = TutorialKind.achievement
      ..markContextPresented(TutorialKind.achievement);
    final usecase = MarkTutorialContextSeenUsecaseImpl(
      repository: repository,
      session: session,
    );
    await usecase.execute(
      const MarkTutorialContextSeenRequest(kind: TutorialKind.achievement),
    );
    expect(
      (await repository.read()).achievementContextSeen,
      isTrue,
      reason: 'achievementContextSeen が true になること',
    );
    expect(session.isShowing, isFalse, reason: 'session が非表示になること');
  });
}
