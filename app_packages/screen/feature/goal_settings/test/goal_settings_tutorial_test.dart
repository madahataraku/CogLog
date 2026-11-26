import 'package:data_repository_daily_goal_testing/data_repository_daily_goal_testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_goal_settings/screen_feature_goal_settings.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_daily_goal/usecase_load_daily_goal.dart';
import 'package:usecase_load_daily_goal_impl/usecase_load_daily_goal_impl.dart';
import 'package:usecase_save_daily_goal/usecase_save_daily_goal.dart';
import 'package:usecase_save_daily_goal_impl/usecase_save_daily_goal_impl.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

final class _EvaluateTutorial implements EvaluateTutorialContextUsecase {
  _EvaluateTutorial({required this.shouldShow, this.session});

  final bool shouldShow;
  final TutorialRuntimeSession? session;
  var calls = 0;

  @override
  Future<EvaluateTutorialContextResult> execute(
    EvaluateTutorialContextRequest request,
  ) async {
    calls += 1;
    expect(request.kind, TutorialKind.goalSettings);
    if (shouldShow) {
      session?.activeKind = TutorialKind.goalSettings;
      session?.markContextPresented(TutorialKind.goalSettings);
    }
    return EvaluateTutorialContextResult(shouldShow: shouldShow);
  }
}

final class _MarkTutorialSeen implements MarkTutorialContextSeenUsecase {
  var calls = 0;

  @override
  Future<void> execute(MarkTutorialContextSeenRequest request) async {
    calls += 1;
    expect(request.kind, TutorialKind.goalSettings);
  }
}

final class _AdvanceTutorial implements AdvanceTutorialMainUsecase {
  @override
  Future<AdvanceTutorialMainResult> execute(
    AdvanceTutorialMainRequest request,
  ) async {
    return const AdvanceTutorialMainResult.noop();
  }
}

Future<void> _pumpFrames(WidgetTester tester, {int count = 12}) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUp(() async {
    await LocalizeStringDelegate.injectDelegateForTest(
      arbJson: StringsTestHelper.ja,
    );
  });

  tearDown(() async {
    CoachMarkLauncher.dismissActive();
    await Future<void>.delayed(Duration.zero);
    LocalizeStringDelegate.resetDelegateForTest();
  });

  // テスト対象:
  // GoalSettingsScreen 文脈評価とコーチマーク表示
  //
  // テスト内容:
  // 目標タブ選択かつ読込後、Evaluate が true なら1手目が出る。
  testWidgets('タブ選択かつ読込後に目標設定文脈の1手目が出る', (tester) async {
    final goals = MemoryDailyGoalRepository();
    final session = TutorialRuntimeSession();
    final evaluate = _EvaluateTutorial(shouldShow: true, session: session);
    final markSeen = _MarkTutorialSeen();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          LoadDailyGoalUsecase.provider.overrideWith(
            (ref) => LoadDailyGoalUsecaseImpl(goals: goals),
          ),
          SaveDailyGoalUsecase.provider.overrideWith(
            (ref) => SaveDailyGoalUsecaseImpl(goals: goals),
          ),
          AdvanceTutorialMainUsecase.provider.overrideWith(
            (ref) => _AdvanceTutorial(),
          ),
          EvaluateTutorialContextUsecase.provider.overrideWith(
            (ref) => evaluate,
          ),
          MarkTutorialContextSeenUsecase.provider.overrideWith(
            (ref) => markSeen,
          ),
          tutorialRuntimeSessionProvider.overrideWith((ref) => session),
          CoachMarkProviders.registry.overrideWith(
            (ref) => CoachMarkRegistry(),
          ),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemeData(touch: true, colors: FColors.neutralLight),
            child: ShellTabIndexScope(
              index: 4,
              child: const GoalSettingsScreen(),
            ),
          ),
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(evaluate.calls, greaterThanOrEqualTo(1));
    expect(
      find.text('目標設定のやり方①'),
      findsOneWidget,
      reason: 'goalSettings context step 1 should appear',
    );
  });

  // テスト対象:
  // GoalSettingsScreen のタブ離脱クリーンアップ
  //
  // テスト内容:
  // 表示中に目標タブを離れるとオーバーレイを閉じ、session をロールバックする。
  testWidgets('タブ離脱でコーチマークを閉じ session を戻す', (tester) async {
    final goals = MemoryDailyGoalRepository();
    final session = TutorialRuntimeSession();
    final evaluate = _EvaluateTutorial(shouldShow: true, session: session);
    final markSeen = _MarkTutorialSeen();

    Future<void> pumpAtTab(int index) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            LoadDailyGoalUsecase.provider.overrideWith(
              (ref) => LoadDailyGoalUsecaseImpl(goals: goals),
            ),
            SaveDailyGoalUsecase.provider.overrideWith(
              (ref) => SaveDailyGoalUsecaseImpl(goals: goals),
            ),
            AdvanceTutorialMainUsecase.provider.overrideWith(
              (ref) => _AdvanceTutorial(),
            ),
            EvaluateTutorialContextUsecase.provider.overrideWith(
              (ref) => evaluate,
            ),
            MarkTutorialContextSeenUsecase.provider.overrideWith(
              (ref) => markSeen,
            ),
            tutorialRuntimeSessionProvider.overrideWith((ref) => session),
            CoachMarkProviders.registry.overrideWith(
              (ref) => CoachMarkRegistry(),
            ),
          ],
          child: MaterialApp(
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: ShellTabIndexScope(
                index: index,
                child: const GoalSettingsScreen(),
              ),
            ),
          ),
        ),
      );
    }

    await pumpAtTab(4);
    await _pumpFrames(tester);
    expect(find.text('目標設定のやり方①'), findsOneWidget);
    expect(session.activeKind, TutorialKind.goalSettings);

    await pumpAtTab(0);
    await _pumpFrames(tester);

    expect(find.text('目標設定のやり方①'), findsNothing);
    expect(session.activeKind, isNull);
    expect(session.hasContextPresentedThisProcess(TutorialKind.goalSettings), isFalse);
  });

  // テスト対象:
  // GoalSettingsScreen のタブ未選択時
  //
  // テスト内容:
  // 目標タブ以外では Evaluate しない。
  testWidgets('目標タブ未選択では文脈を評価しない', (tester) async {
    final goals = MemoryDailyGoalRepository();
    final evaluate = _EvaluateTutorial(shouldShow: true);
    final markSeen = _MarkTutorialSeen();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          LoadDailyGoalUsecase.provider.overrideWith(
            (ref) => LoadDailyGoalUsecaseImpl(goals: goals),
          ),
          SaveDailyGoalUsecase.provider.overrideWith(
            (ref) => SaveDailyGoalUsecaseImpl(goals: goals),
          ),
          AdvanceTutorialMainUsecase.provider.overrideWith(
            (ref) => _AdvanceTutorial(),
          ),
          EvaluateTutorialContextUsecase.provider.overrideWith(
            (ref) => evaluate,
          ),
          MarkTutorialContextSeenUsecase.provider.overrideWith(
            (ref) => markSeen,
          ),
          tutorialRuntimeSessionProvider.overrideWith(
            (ref) => TutorialRuntimeSession(),
          ),
          CoachMarkProviders.registry.overrideWith(
            (ref) => CoachMarkRegistry(),
          ),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemeData(touch: true, colors: FColors.neutralLight),
            child: ShellTabIndexScope(
              index: 0,
              child: const GoalSettingsScreen(),
            ),
          ),
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(evaluate.calls, 0);
    expect(find.text('目標設定のやり方①'), findsNothing);
  });
}
