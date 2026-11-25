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

  // テスト対象:
  // EvaluateTutorialContextUsecaseImpl.execute
  //
  // テスト内容:
  // 永続の seen 済みなら shouldShow は false。
  test('seen → false', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(cameraContextSeen: true),
    );
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.camera),
    );
    expect(result.shouldShow, isFalse, reason: 'seen 済みは出さないこと');
  });

  // テスト対象:
  // EvaluateTutorialContextUsecaseImpl.execute
  //
  // テスト内容:
  // 未 seen なら true になり、session.activeKind が文脈になる。
  test('未 seen → true', () async {
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.camera),
    );
    expect(result.shouldShow, isTrue, reason: '未 seen は出すこと');
    expect(
      session.activeKind,
      TutorialKind.camera,
      reason: 'session.activeKind が camera になること',
    );
  });

  // テスト対象:
  // EvaluateTutorialContextUsecaseImpl.execute / achievement
  //
  // テスト内容:
  // main 未完了のアチーブメント文脈は出さない。
  test('achievement は main 未完了 → false', () async {
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(
        kind: TutorialKind.achievement,
        unlockedAchievementCount: 2,
      ),
    );
    expect(result.shouldShow, isFalse, reason: 'main 未完了では出さないこと');
  });

  // テスト対象:
  // EvaluateTutorialContextUsecaseImpl.execute / achievement
  //
  // テスト内容:
  // 獲得 0 件なら出さない。
  test('achievement は 0 件 → false', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(mainCompleted: true),
    );
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(
        kind: TutorialKind.achievement,
        unlockedAchievementCount: 0,
      ),
    );
    expect(result.shouldShow, isFalse, reason: '獲得 0 件では出さないこと');
  });

  // テスト対象:
  // EvaluateTutorialContextUsecaseImpl.execute / achievement
  //
  // テスト内容:
  // main 完了かつ 1 件以上なら出す。
  test('achievement は main 完了かつ 1 件以上 → true', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(mainCompleted: true),
    );
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(
        kind: TutorialKind.achievement,
        unlockedAchievementCount: 1,
      ),
    );
    expect(result.shouldShow, isTrue, reason: '条件満たせば出すこと');
  });

  // テスト対象:
  // EvaluateTutorialContextUsecaseImpl.execute / main 中断
  //
  // テスト内容:
  // メイン表示中に文脈を出すと interrupt し、mainStep を消す。
  test('main 表示中 → interrupt して true', () async {
    session.activeKind = TutorialKind.main;
    session.mainStep = TutorialMainStep.homeIntro;
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.trends),
    );
    expect(result.shouldShow, isTrue, reason: '文脈を出せること');
    expect(
      session.activeKind,
      TutorialKind.trends,
      reason: 'activeKind が trends に切り替わること',
    );
    expect(session.mainStep, isNull, reason: 'mainStep が消えること');
  });

  // テスト対象:
  // EvaluateTutorialContextUsecaseImpl.execute / 他文脈
  //
  // テスト内容:
  // 別文脈表示中は同時に出さない。
  test('他文脈表示中 → false', () async {
    session.activeKind = TutorialKind.camera;
    final result = await usecase.execute(
      const EvaluateTutorialContextRequest(kind: TutorialKind.trends),
    );
    expect(result.shouldShow, isFalse, reason: '他文脈表示中は出さないこと');
  });
}
