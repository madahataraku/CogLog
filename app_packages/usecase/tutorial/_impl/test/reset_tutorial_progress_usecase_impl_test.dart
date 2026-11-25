import 'package:data_repository_tutorial_testing/data_repository_tutorial_testing.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:test/test.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:usecase_tutorial_impl/usecase_tutorial_impl.dart';

void main() {
  // テスト対象:
  // ResetTutorialProgressUsecaseImpl.execute
  //
  // テスト内容:
  // 永続を initial に戻し、表示中とプロセス内提示済みを消し、manualStartGuard を立てる。
  test('write(initial) + guard', () async {
    final repository = MemoryTutorialRepository();
    await repository.write(
      TutorialProgress.initial.copyWith(
        mainCompleted: true,
        cameraContextSeen: true,
      ),
    );
    final session = TutorialRuntimeSession()
      ..activeKind = TutorialKind.main
      ..mainStep = TutorialMainStep.homeIntro
      ..markContextPresented(TutorialKind.camera);
    final usecase = ResetTutorialProgressUsecaseImpl(
      repository: repository,
      session: session,
    );
    await usecase.execute();
    expect(
      await repository.read(),
      TutorialProgress.initial,
      reason: '進捗が initial に戻ること',
    );
    expect(session.isShowing, isFalse, reason: 'session が非表示になること');
    expect(session.manualStartGuard, isTrue, reason: 'manualStartGuard が立つこと');
    expect(
      session.hasContextPresentedThisProcess(TutorialKind.camera),
      isFalse,
      reason: 'プロセス内提示済みが消えること',
    );
  });
}
