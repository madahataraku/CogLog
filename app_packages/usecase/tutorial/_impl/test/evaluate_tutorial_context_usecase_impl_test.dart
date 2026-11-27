import 'package:data_repository_tutorial_testing/data_repository_tutorial_testing.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:test/test.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:usecase_tutorial_impl/usecase_tutorial_impl.dart';

void main() {
  late MemoryTutorialRepository repository;
  late TutorialRuntimeSession session;
  late EvaluateTutorialContextUsecaseImpl usecase;

  setUp(() {
    repository = MemoryTutorialRepository();
    session = TutorialRuntimeSession();
    usecase = EvaluateTutorialContextUsecaseImpl(
      repository: repository,
      session: session,
    );
  });

  test('seen → false', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(cameraContextSeen: true),
    );
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.camera),
    );
    expect(result.shouldShow, isFalse);
  });

  test('未 seen → true', () async {
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.camera),
    );
    expect(result.shouldShow, isTrue);
    expect(session.activeKind, TutorialKind.camera);
  });

  test('goalSettings は到達3未満 → false', () async {
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.goalSettings),
    );
    expect(result.shouldShow, isFalse);
  });

  test('goalSettings は到達3以上で未 seen → true', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(mainReachedStep: 3),
    );
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.goalSettings),
    );
    expect(result.shouldShow, isTrue);
    expect(session.activeKind, TutorialKind.goalSettings);
  });

  test('main 表示中 → interrupt して true', () async {
    session.activeKind = TutorialKind.main;
    session.mainStep = TutorialMainStep.homeIntro;
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.trends),
    );
    expect(result.shouldShow, isTrue);
    expect(session.activeKind, TutorialKind.trends);
    expect(session.mainStep, isNull);
  });

  test('他文脈表示中 → false', () async {
    session.activeKind = TutorialKind.camera;
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.trends),
    );
    expect(result.shouldShow, isFalse);
  });

  test('提示済みクリア後は goalSettings を再評価できる', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(mainReachedStep: 3),
    );
    final first = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.goalSettings),
    );
    expect(first.shouldShow, isTrue);
    session
      ..clearActive()
      ..clearContextPresented(TutorialKind.goalSettings);
    final second = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.goalSettings),
    );
    expect(second.shouldShow, isTrue);
    expect(session.activeKind, TutorialKind.goalSettings);
  });

  test('achievement 未 seen → true', () async {
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.achievement),
    );
    expect(result.shouldShow, isTrue);
    expect(session.activeKind, TutorialKind.achievement);
  });

  test('achievement seen → false', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(achievementContextSeen: true),
    );
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.achievement),
    );
    expect(result.shouldShow, isFalse);
  });

  test('読込後に提示済みなら二重評価は false', () async {
    final first = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.achievement),
    );
    expect(first.shouldShow, isTrue);
    // 第1評価が markContextPresented 済みの状態で、読込後再確認が効くことを直接検証。
    final second = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.achievement),
    );
    expect(second.shouldShow, isFalse);
    expect(session.activeKind, TutorialKind.achievement);
  });
}
