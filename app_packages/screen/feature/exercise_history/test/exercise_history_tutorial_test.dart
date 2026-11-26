import 'package:data_repository_exercise_history_testing/data_repository_exercise_history_testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_exercise_history/screen_feature_exercise_history.dart';
import 'package:screen_navigation/screen_navigation.dart';
import 'package:usecase_load_exercise_history_month/usecase_load_exercise_history_month.dart';
import 'package:usecase_load_exercise_history_month_impl/usecase_load_exercise_history_month_impl.dart';
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
    expect(request.kind, TutorialKind.history);
    if (shouldShow) {
      session?.activeKind = TutorialKind.history;
      session?.markContextPresented(TutorialKind.history);
    }
    return EvaluateTutorialContextResult(shouldShow: shouldShow);
  }
}

final class _MarkTutorialSeen implements MarkTutorialContextSeenUsecase {
  var calls = 0;

  @override
  Future<void> execute(MarkTutorialContextSeenRequest request) async {
    calls += 1;
    expect(request.kind, TutorialKind.history);
  }
}

final class _Nav implements ScreenNavigation {
  @override
  void openExerciseHistoryDetail({required String id}) {}

  @override
  Future<ExerciseHistoryEditPopResult?> openExerciseHistoryEditAndWait({
    required String id,
  }) async => null;

  @override
  void openAppSettings() {}

  @override
  Future<void> openAchievements() async {}

  @override
  void openDebug() {}

  @override
  void openNotificationSettings() {}

  @override
  void openDataManagement() {}

  @override
  void openOssLicenses() {}

  @override
  void openOssLicenseDetail({required String packageName}) {}

  @override
  void pop() {}

  @override
  void popWithResult<T extends Object?>(T result) {}

  @override
  void goToHomeTab() {}

  @override
  void goToGoalSettingsTab() {}

  @override
  void goToMeterCaptureTab() {}
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
  // ExerciseHistoryScreen 文脈評価とコーチマーク表示
  //
  // テスト内容:
  // 履歴タブ選択かつ読込後、Evaluate が true なら文脈が出る。
  testWidgets('タブ選択かつ読込後に運動履歴文脈が出る', (tester) async {
    final session = TutorialRuntimeSession();
    final evaluate = _EvaluateTutorial(shouldShow: true, session: session);
    final markSeen = _MarkTutorialSeen();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          LoadExerciseHistoryMonthUsecase.provider.overrideWith(
            (ref) => LoadExerciseHistoryMonthUsecaseImpl(
              histories: const FixedExerciseHistoryRepository([]),
            ),
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
          screenNavigationProvider.overrideWith((ref) => _Nav()),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemeData(touch: true, colors: FColors.neutralLight),
            child: ShellTabIndexScope(
              index: 3,
              child: const ExerciseHistoryScreen(),
            ),
          ),
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(evaluate.calls, greaterThanOrEqualTo(1));
    expect(
      find.text('運動履歴の確認や編集を行おう'),
      findsOneWidget,
      reason: 'history context coach mark should appear',
    );
  });

  // テスト対象:
  // ExerciseHistoryScreen のタブ離脱クリーンアップ
  //
  // テスト内容:
  // 表示中に履歴タブを離れるとオーバーレイを閉じ、session をロールバックする。
  testWidgets('タブ離脱でコーチマークを閉じ session を戻す', (tester) async {
    final session = TutorialRuntimeSession();
    final evaluate = _EvaluateTutorial(shouldShow: true, session: session);
    final markSeen = _MarkTutorialSeen();

    Future<void> pumpAtTab(int index) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            LoadExerciseHistoryMonthUsecase.provider.overrideWith(
              (ref) => LoadExerciseHistoryMonthUsecaseImpl(
                histories: const FixedExerciseHistoryRepository([]),
              ),
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
            screenNavigationProvider.overrideWith((ref) => _Nav()),
          ],
          child: MaterialApp(
            home: FTheme(
              data: FThemeData(touch: true, colors: FColors.neutralLight),
              child: ShellTabIndexScope(
                index: index,
                child: const ExerciseHistoryScreen(),
              ),
            ),
          ),
        ),
      );
    }

    await pumpAtTab(3);
    await _pumpFrames(tester);
    expect(find.text('運動履歴の確認や編集を行おう'), findsOneWidget);
    expect(session.activeKind, TutorialKind.history);

    await pumpAtTab(0);
    await _pumpFrames(tester);

    expect(find.text('運動履歴の確認や編集を行おう'), findsNothing);
    expect(session.activeKind, isNull);
    expect(
      session.hasContextPresentedThisProcess(TutorialKind.history),
      isFalse,
    );
    expect(markSeen.calls, 0);
  });

  // テスト対象:
  // ExerciseHistoryScreen のタブ未選択時
  //
  // テスト内容:
  // 履歴タブ以外では Evaluate しない。
  testWidgets('履歴タブ未選択では文脈を評価しない', (tester) async {
    final evaluate = _EvaluateTutorial(shouldShow: true);
    final markSeen = _MarkTutorialSeen();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          LoadExerciseHistoryMonthUsecase.provider.overrideWith(
            (ref) => LoadExerciseHistoryMonthUsecaseImpl(
              histories: const FixedExerciseHistoryRepository([]),
            ),
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
          screenNavigationProvider.overrideWith((ref) => _Nav()),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemeData(touch: true, colors: FColors.neutralLight),
            child: ShellTabIndexScope(
              index: 0,
              child: const ExerciseHistoryScreen(),
            ),
          ),
        ),
      ),
    );
    await _pumpFrames(tester);

    expect(evaluate.calls, 0);
    expect(find.text('運動履歴の確認や編集を行おう'), findsNothing);
  });
}
