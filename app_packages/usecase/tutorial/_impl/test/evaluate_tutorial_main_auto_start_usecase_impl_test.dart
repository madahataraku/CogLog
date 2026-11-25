import 'package:data_repository_tutorial_testing/data_repository_tutorial_testing.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:test/test.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:usecase_tutorial_impl/usecase_tutorial_impl.dart';

void main() {
  late MemoryTutorialRepository repository;
  late TutorialRuntimeSession session;
  late EvaluateTutorialMainAutoStartUsecaseImpl usecase;

  setUp(() {
    repository = MemoryTutorialRepository();
    session = TutorialRuntimeSession();
    usecase = EvaluateTutorialMainAutoStartUsecaseImpl(
      repository: repository,
      session: session,
    );
  });

  // テスト対象:
  // EvaluateTutorialMainAutoStartUsecaseImpl.execute
  //
  // テスト内容:
  // 未完了・抑止なしなら shouldStart は true。
  test('未完了 → shouldStart true', () async {
    final result = await usecase.execute();
    expect(result.shouldStart, isTrue, reason: '未完了なら開始すること');
  });

  // テスト対象:
  // EvaluateTutorialMainAutoStartUsecaseImpl.execute
  //
  // テスト内容:
  // mainCompleted 済みなら shouldStart は false。
  test('完了 → shouldStart false', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(mainCompleted: true),
    );
    final result = await usecase.execute();
    expect(result.shouldStart, isFalse, reason: '完了済みは開始しないこと');
  });

  // テスト対象:
  // EvaluateTutorialMainAutoStartUsecaseImpl.execute
  //
  // テスト内容:
  // suppress 中は開始しない。
  test('suppress → shouldStart false', () async {
    session.suppressMainAutoStartThisProcess = true;
    final result = await usecase.execute();
    expect(result.shouldStart, isFalse, reason: 'suppress 中は開始しないこと');
  });

  // テスト対象:
  // EvaluateTutorialMainAutoStartUsecaseImpl.execute
  //
  // テスト内容:
  // 表示中は開始しない。
  test('showing → shouldStart false', () async {
    session.activeKind = TutorialKind.main;
    session.mainStep = TutorialMainStep.homeIntro;
    final result = await usecase.execute();
    expect(result.shouldStart, isFalse, reason: '表示中は開始しないこと');
  });

  // テスト対象:
  // EvaluateTutorialMainAutoStartUsecaseImpl.execute
  //
  // テスト内容:
  // manualStartGuard 中は開始しない。
  test('manualStartGuard → shouldStart false', () async {
    session.manualStartGuard = true;
    final result = await usecase.execute();
    expect(result.shouldStart, isFalse, reason: 'manualStartGuard 中は開始しないこと');
  });
}
