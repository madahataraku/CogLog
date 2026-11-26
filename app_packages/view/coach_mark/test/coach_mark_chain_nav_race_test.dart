import 'dart:async';

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

  tearDown(() async {
    CoachMarkLauncher.dismissActive();
    // removeRoute の Focus 微タスクを widget tree dispose 前に吐き出す。
    await Future<void>.delayed(Duration.zero);
    LocalizeStringDelegate.resetDelegateForTest();
  });

  // テスト対象:
  // CoachMarkLauncher 連鎖 show（disableBackButton removeRoute 直後）
  //
  // テスト内容:
  // 主ボタン完了の直後に次段階 show しても欠落しない（同期 complete 競合の回帰）。
  testWidgets('主ボタン直後の連鎖でも次段階が出る', (tester) async {
    final registry = CoachMarkRegistry();
    late BuildContext ctx;

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            ctx = context;
            return Column(
              children: [
                CoachMarkTarget(
                  id: CoachMarkTargetId.homePeriodTotals,
                  child: const SizedBox(
                    width: 100,
                    height: 40,
                    child: Text('a'),
                  ),
                ),
                CoachMarkTarget(
                  id: CoachMarkTargetId.homeGoalRings,
                  child: const SizedBox(
                    width: 100,
                    height: 40,
                    child: Text('b'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pump();

    final reasons = <CoachMarkDismissReason>[];
    final done = Completer<void>();
    unawaited(() async {
      final r1 = await CoachMarkLauncher.show(
        ctx,
        step: const CoachMarkStep(
          targetId: CoachMarkTargetId.homePeriodTotals,
          title: 's1',
          body: 'b1',
          primaryLabel: '次へ',
        ),
      );
      reasons.add(r1);
      final r2 = await CoachMarkLauncher.show(
        ctx,
        step: const CoachMarkStep(
          targetId: CoachMarkTargetId.homeGoalRings,
          title: 's2',
          body: 'b2',
          primaryLabel: '次へ',
        ),
      );
      reasons.add(r2);
      done.complete();
    }());

    await _pumpFrames(tester);
    expect(find.text('s1'), findsOneWidget);

    await tester.tap(find.text('次へ'));
    // 完了微タスク → 次 show の Duration.zero insert を進める。
    await tester.pump();
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);
    await _pumpFrames(tester);

    expect(find.text('s2'), findsOneWidget, reason: 'reasons=$reasons');

    await tester.tap(find.text('次へ'));
    await _pumpFrames(tester, count: 5);
    await done.future;
    expect(reasons, [
      CoachMarkDismissReason.primary,
      CoachMarkDismissReason.primary,
    ]);
  });
}
