import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:data_repository_tutorial_testing/data_repository_tutorial_testing.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:test/test.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:usecase_tutorial_impl/usecase_tutorial_impl.dart';

/// write だけ失敗する TutorialRepository。
final class _FailingTutorialRepository implements TutorialRepository {
  @override
  Future<TutorialProgress> read() async => TutorialProgress.initial;

  @override
  Future<void> write(TutorialProgress progress) async {
    throw StateError('write failed');
  }
}

void main() {
  late MemoryTutorialRepository repository;
  late TutorialRuntimeSession session;

  AdvanceTutorialMainUsecaseImpl usecase() {
    return AdvanceTutorialMainUsecaseImpl(
      repository: repository,
      session: session,
    );
  }

  setUp(() {
    repository = MemoryTutorialRepository();
    session = TutorialRuntimeSession();
  });

  test('start → usageIntro', () async {
    final result = await usecase().execute(
      const AdvanceTutorialMainRequest.start(),
    );
    expect(
      result,
      isA<AdvanceTutorialMainShowResult>()
          .having((e) => e.step, 'step', TutorialMainStep.usageIntro)
          .having(
            (e) => e.navigation,
            'nav',
            AdvanceTutorialMainNavigation.none,
          ),
    );
    expect(session.mainStep, TutorialMainStep.usageIntro);
  });

  test('メイン表示中の start は noop（二重連鎖防止）', () async {
    await usecase().execute(const AdvanceTutorialMainRequest.start());
    final second = await usecase().execute(
      const AdvanceTutorialMainRequest.start(),
    );
    expect(second, isA<AdvanceTutorialMainNoopResult>());
    expect(session.mainStep, TutorialMainStep.usageIntro);
  });

  test('読込み後に文脈が有効なら start は noop', () async {
    session.activeKind = TutorialKind.camera;
    final result = await usecase().execute(
      const AdvanceTutorialMainRequest.start(),
    );
    expect(result, isA<AdvanceTutorialMainNoopResult>());
    expect(session.activeKind, TutorialKind.camera);
    expect(session.mainStep, isNull);
  });

  test('導入→1→2→3', () async {
    final u = usecase();
    await u.execute(const AdvanceTutorialMainRequest.start());
    final r1 = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r1 as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.homeIntro,
    );
    expect((await repository.read()).mainReachedStep, 0);
    final r2 = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r2 as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.goalProgressIntro,
    );
    final r3 = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r3 as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.goalRecommend,
    );
    expect(r3.navigation, AdvanceTutorialMainNavigation.none);
  });

  test('段階3 next で到達3・目標タブ誘導', () async {
    final u = usecase();
    await u.execute(const AdvanceTutorialMainRequest.start());
    await u.execute(const AdvanceTutorialMainRequest.next());
    await u.execute(const AdvanceTutorialMainRequest.next());
    await u.execute(const AdvanceTutorialMainRequest.next());
    final r = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r as AdvanceTutorialMainShowResult).navigation,
      AdvanceTutorialMainNavigation.goalSettingsTab,
    );
    expect((await repository.read()).mainReachedStep, 3);
    expect(session.isShowing, isFalse);
  });

  test('段階3 write 失敗で suppress', () async {
    session = TutorialRuntimeSession();
    final failing = AdvanceTutorialMainUsecaseImpl(
      repository: _FailingTutorialRepository(),
      session: session,
    );
    await failing.execute(const AdvanceTutorialMainRequest.start());
    await failing.execute(const AdvanceTutorialMainRequest.next());
    await failing.execute(const AdvanceTutorialMainRequest.next());
    await failing.execute(const AdvanceTutorialMainRequest.next());
    final r = await failing.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r as AdvanceTutorialMainShowResult).navigation,
      AdvanceTutorialMainNavigation.goalSettingsTab,
    );
    expect(session.suppressMainAutoStartThisProcess, isTrue);
  });

  test('目標文脈済みなら start で段階4', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(
        mainReachedStep: 3,
        goalSettingsContextSeen: true,
      ),
    );
    final r = await usecase().execute(const AdvanceTutorialMainRequest.start());
    expect(
      (r as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.meterRecommend,
    );
  });

  test('段階4 next は到達4・メータータブ誘導・未完了', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(
        mainReachedStep: 3,
        goalSettingsContextSeen: true,
      ),
    );
    final u = usecase();
    await u.execute(const AdvanceTutorialMainRequest.start());
    final r = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r as AdvanceTutorialMainShowResult).navigation,
      AdvanceTutorialMainNavigation.meterCaptureTab,
    );
    final progress = await repository.read();
    expect(progress.mainReachedStep, 4);
    expect(progress.mainCompleted, isFalse);
  });

  test('段階5 next は到達5・推移タブ誘導', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(
        mainReachedStep: 4,
        cameraContextSeen: true,
        meterEditContextSeen: true,
      ),
    );
    final u = usecase();
    await u.execute(const AdvanceTutorialMainRequest.start());
    final r = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r as AdvanceTutorialMainShowResult).navigation,
      AdvanceTutorialMainNavigation.trendsTab,
    );
    expect((await repository.read()).mainReachedStep, 5);
  });

  test('段階6 next は到達6・履歴タブ誘導', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(
        mainReachedStep: 5,
        trendsContextSeen: true,
      ),
    );
    final u = usecase();
    await u.execute(const AdvanceTutorialMainRequest.start());
    final r = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r as AdvanceTutorialMainShowResult).navigation,
      AdvanceTutorialMainNavigation.exerciseHistoryTab,
    );
    expect((await repository.read()).mainReachedStep, 6);
  });

  test('段階7 next で completed・アチーブメント誘導', () async {
    await repository.write(
      TutorialProgress.initial.copyWith(
        mainReachedStep: 6,
        historyContextSeen: true,
      ),
    );
    final u = usecase();
    final show = await u.execute(const AdvanceTutorialMainRequest.start());
    expect(
      (show as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.achievementRecommend,
    );
    final r = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      r,
      isA<AdvanceTutorialMainCompletedResult>().having(
        (e) => e.navigation,
        'nav',
        AdvanceTutorialMainNavigation.achievements,
      ),
    );
    expect((await repository.read()).mainCompleted, isTrue);
  });
}
