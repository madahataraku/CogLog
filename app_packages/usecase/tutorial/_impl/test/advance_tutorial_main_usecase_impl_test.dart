import 'package:data_repository_tutorial/data_repository_tutorial.dart';
import 'package:data_repository_tutorial_testing/data_repository_tutorial_testing.dart';
import 'package:domain_daily_goal/domain_daily_goal.dart';
import 'package:domain_tutorial/domain_tutorial.dart';
import 'package:test/test.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:usecase_tutorial_impl/usecase_tutorial_impl.dart';

/// 固定の [DailyGoal] を返す LoadDailyGoal の差し替え。
final class _FakeLoadDailyGoal implements LoadDailyGoalUsecase {
  /// [goal] をそのまま返す。
  ///
  /// Example:
  /// ```dart
  /// _FakeLoadDailyGoal(DailyGoal.unset);
  /// ```
  _FakeLoadDailyGoal(this.goal);

  /// 返す一日あたり目標。
  final DailyGoal goal;

  /// [goal] と既定の自動更新設定を返す。
  ///
  /// Example:
  /// ```dart
  /// await fake.execute(const LoadDailyGoalRequest());
  /// ```
  @override
  Future<LoadDailyGoalResult> execute(LoadDailyGoalRequest request) async {
    return LoadDailyGoalResult(
      goal: goal,
      autoUpdate: DailyGoalAutoUpdateSettings.defaults,
    );
  }
}

/// write だけ失敗する TutorialRepository。
final class _FailingTutorialRepository implements TutorialRepository {
  /// 常に initial を返す。
  ///
  /// Example:
  /// ```dart
  /// await repository.read();
  /// ```
  @override
  Future<TutorialProgress> read() async => TutorialProgress.initial;

  /// 常に失敗する。
  ///
  /// Example:
  /// ```dart
  /// await repository.write(TutorialProgress.initial);
  /// ```
  @override
  Future<void> write(TutorialProgress progress) async {
    throw StateError('write failed');
  }
}

void main() {
  late MemoryTutorialRepository repository;
  late TutorialRuntimeSession session;

  /// 共通依存で Usecase を組み立てる。
  ///
  /// Example:
  /// ```dart
  /// usecase();
  /// ```
  AdvanceTutorialMainUsecaseImpl usecase({DailyGoal? goal}) {
    return AdvanceTutorialMainUsecaseImpl(
      repository: repository,
      session: session,
      loadDailyGoal: _FakeLoadDailyGoal(goal ?? DailyGoal.unset),
    );
  }

  setUp(() {
    repository = MemoryTutorialRepository();
    session = TutorialRuntimeSession();
  });

  // テスト対象:
  // AdvanceTutorialMainUsecaseImpl.execute(start)
  //
  // テスト内容:
  // start 直後は homeIntro を show し、session.mainStep も同じになる。
  test('start → homeIntro', () async {
    final result = await usecase().execute(
      const AdvanceTutorialMainRequest.start(),
    );
    expect(
      result,
      isA<AdvanceTutorialMainShowResult>()
          .having((e) => e.step, 'step', TutorialMainStep.homeIntro)
          .having((e) => e.navigateToGoalTab, 'nav', isFalse),
      reason: 'start は homeIntro の show であること',
    );
    expect(
      session.mainStep,
      TutorialMainStep.homeIntro,
      reason: 'session.mainStep が homeIntro であること',
    );
  });

  // テスト対象:
  // AdvanceTutorialMainUsecaseImpl.execute(next) / 目標未設定
  //
  // テスト内容:
  // 1→2→3 と進み、段階3では目標タブ誘導が true になる。
  test('1→2→3（目標未設定）', () async {
    final u = usecase();
    await u.execute(const AdvanceTutorialMainRequest.start());
    final r2 = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r2 as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.tabOverview,
      reason: '1→2 で tabOverview になること',
    );
    final r3 = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r3 as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.goalRecommend,
      reason: '目標未設定なら 2→3 で goalRecommend になること',
    );
    expect(r3.navigateToGoalTab, isTrue, reason: '段階3は目標タブ誘導すること');
  });

  // テスト対象:
  // AdvanceTutorialMainUsecaseImpl.execute(next) / 3指標済み
  //
  // テスト内容:
  // 目標が揃っているとき 2→4 へ飛び、目標タブ誘導はしない。
  test('3指標済みで 2→4', () async {
    final u = usecase(
      goal: const DailyGoal(
        duration: Duration.zero,
        caloriesKcal: 0,
        distanceKm: 0,
      ),
    );
    await u.execute(const AdvanceTutorialMainRequest.start());
    await u.execute(const AdvanceTutorialMainRequest.next());
    final r = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      (r as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.meterRecommend,
      reason: '3指標済みなら 2→4 で meterRecommend になること',
    );
    expect(r.navigateToGoalTab, isFalse, reason: '段階4では目標タブ誘導しないこと');
  });

  // テスト対象:
  // AdvanceTutorialMainUsecaseImpl.execute(goalSaved)
  //
  // テスト内容:
  // 段階3からの goalSaved は meterRecommend へ進む。
  test('goalSaved → 4', () async {
    final u = usecase();
    await u.execute(const AdvanceTutorialMainRequest.start());
    await u.execute(const AdvanceTutorialMainRequest.next());
    await u.execute(const AdvanceTutorialMainRequest.next());
    final r = await u.execute(const AdvanceTutorialMainRequest.goalSaved());
    expect(
      (r as AdvanceTutorialMainShowResult).step,
      TutorialMainStep.meterRecommend,
      reason: 'goalSaved は meterRecommend になること',
    );
  });

  // テスト対象:
  // AdvanceTutorialMainUsecaseImpl.execute(skip)
  //
  // テスト内容:
  // 段階3スキップは completed と永続 mainCompleted、session 非表示になる。
  test('skip で completed + write', () async {
    final u = usecase();
    await u.execute(const AdvanceTutorialMainRequest.start());
    await u.execute(const AdvanceTutorialMainRequest.next());
    await u.execute(const AdvanceTutorialMainRequest.next());
    final r = await u.execute(const AdvanceTutorialMainRequest.skip());
    expect(
      r,
      isA<AdvanceTutorialMainCompletedResult>(),
      reason: 'skip は completed であること',
    );
    expect(
      (await repository.read()).mainCompleted,
      isTrue,
      reason: 'mainCompleted が永続されること',
    );
    expect(session.isShowing, isFalse, reason: 'session が非表示になること');
  });

  // テスト対象:
  // AdvanceTutorialMainUsecaseImpl.execute(skip) / write 失敗
  //
  // テスト内容:
  // 完了書込失敗でも completed を返し、suppress を立てる。
  test('write 失敗で suppress', () async {
    session = TutorialRuntimeSession();
    final failing = AdvanceTutorialMainUsecaseImpl(
      repository: _FailingTutorialRepository(),
      session: session,
      loadDailyGoal: _FakeLoadDailyGoal(DailyGoal.unset),
    );
    await failing.execute(const AdvanceTutorialMainRequest.start());
    await failing.execute(const AdvanceTutorialMainRequest.next());
    await failing.execute(const AdvanceTutorialMainRequest.next());
    final r = await failing.execute(const AdvanceTutorialMainRequest.skip());
    expect(
      r,
      isA<AdvanceTutorialMainCompletedResult>(),
      reason: '書込失敗でも completed を返すこと',
    );
    expect(
      session.suppressMainAutoStartThisProcess,
      isTrue,
      reason: '書込失敗時は suppress が立つこと',
    );
  });

  // テスト対象:
  // AdvanceTutorialMainUsecaseImpl.execute(next) / meterRecommend
  //
  // テスト内容:
  // 段階4の next は completed と永続 mainCompleted になる。
  test('meterRecommend next で completed', () async {
    final u = usecase(
      goal: const DailyGoal(
        duration: Duration.zero,
        caloriesKcal: 0,
        distanceKm: 0,
      ),
    );
    await u.execute(const AdvanceTutorialMainRequest.start());
    await u.execute(const AdvanceTutorialMainRequest.next());
    await u.execute(const AdvanceTutorialMainRequest.next());
    final r = await u.execute(const AdvanceTutorialMainRequest.next());
    expect(
      r,
      isA<AdvanceTutorialMainCompletedResult>(),
      reason: '段階4 next は completed であること',
    );
    expect(
      (await repository.read()).mainCompleted,
      isTrue,
      reason: 'mainCompleted が永続されること',
    );
  });
}
