import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:view_coach_mark/view_coach_mark.dart';

Widget _wrap({required Widget child, required CoachMarkRegistry registry}) {
  return ProviderScope(
    overrides: [CoachMarkProviders.registry.overrideWith((ref) => registry)],
    child: MaterialApp(
      builder: (context, child) => FTheme(
        data: FThemeData(touch: true, colors: FColors.neutralLight),
        child: child!,
      ),
      home: Scaffold(body: child),
    ),
  );
}

Future<void> _pumpFrames(WidgetTester tester, {int count = 10}) async {
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

  tearDown(() {
    CoachMarkLauncher.dismissActive();
    LocalizeStringDelegate.resetDelegateForTest();
  });

  // テスト対象:
  // CoachMarkLauncher.show の同一コールバック内連鎖（ホーム段階1→2相当）
  //
  // テスト内容:
  // 主ボタンのあと次の段階が表示される。
  testWidgets('主ボタン後に次段階が連鎖表示される', (tester) async {
    final registry = CoachMarkRegistry();
    late BuildContext savedContext;

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return Column(
              children: [
                CoachMarkTarget(
                  id: CoachMarkTargetId.homePeriodTotals,
                  child: const SizedBox(
                    width: 200,
                    height: 80,
                    child: Text('t1'),
                  ),
                ),
                CoachMarkTarget(
                  id: CoachMarkTargetId.homeGoalRings,
                  child: const SizedBox(
                    width: 200,
                    height: 80,
                    child: Text('t2'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();

    Future<void> showChain() async {
      var step = 1;
      while (true) {
        final target = step == 1
            ? CoachMarkTargetId.homePeriodTotals
            : CoachMarkTargetId.homeGoalRings;
        final reason = await CoachMarkLauncher.show(
          savedContext,
          step: CoachMarkStep(
            targetId: target,
            title: 'step$step',
            body: 'body$step',
            primaryLabel: '次へ',
          ),
        );
        if (reason != CoachMarkDismissReason.primary) {
          return;
        }
        if (step >= 2) {
          return;
        }
        step++;
        await WidgetsBinding.instance.endOfFrame;
      }
    }

    final chain = showChain();
    await _pumpFrames(tester);
    expect(find.text('step1'), findsOneWidget);

    await tester.tap(find.text('次へ'));
    await _pumpFrames(tester);

    expect(find.text('step2'), findsOneWidget);

    await tester.tap(find.text('次へ'));
    await _pumpFrames(tester);
    await chain;
  });

  // テスト対象:
  // ホーム段階1表示中に無差別 dismissActive した場合の連鎖停止
  //
  // テスト内容:
  // forced 破棄で連鎖が止まり段階2は出ない（撮影タブが main を閉じた旧不具合の症状）。
  // 撮影タブ側は shouldDismissCoachMarkForMeterTutorial(main)==false で閉じない。
  testWidgets('表示中の forced 破棄で連鎖が止まる', (tester) async {
    final registry = CoachMarkRegistry();
    late BuildContext savedContext;

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            savedContext = context;
            return CoachMarkTarget(
              id: CoachMarkTargetId.homePeriodTotals,
              child: const SizedBox(width: 200, height: 80, child: Text('t1')),
            );
          },
        ),
      ),
    );
    await tester.pump();

    var reachedStep2 = false;
    Future<void> showChain() async {
      final reason1 = await CoachMarkLauncher.show(
        savedContext,
        step: const CoachMarkStep(
          targetId: CoachMarkTargetId.homePeriodTotals,
          title: 'step1',
          body: 'body1',
          primaryLabel: '次へ',
        ),
      );
      if (reason1 == CoachMarkDismissReason.forced) {
        return;
      }
      reachedStep2 = true;
      await CoachMarkLauncher.show(
        savedContext,
        step: const CoachMarkStep(
          targetId: CoachMarkTargetId.homeGoalRings,
          title: 'step2',
          body: 'body2',
          primaryLabel: '次へ',
        ),
      );
    }

    final chain = showChain();
    await _pumpFrames(tester);
    expect(find.text('step1'), findsOneWidget);

    CoachMarkLauncher.dismissActive();
    await _pumpFrames(tester);
    await chain;

    expect(reachedStep2, isFalse);
    expect(find.text('step2'), findsNothing);
  });
}
