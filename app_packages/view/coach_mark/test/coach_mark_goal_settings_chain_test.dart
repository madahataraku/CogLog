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
    await Future<void>.delayed(Duration.zero);
    LocalizeStringDelegate.resetDelegateForTest();
  });

  // テスト対象:
  // CoachMarkLauncher 目標設定文脈相当の 3 手連鎖
  //
  // テスト内容:
  // 主ボタン完了の直後に次手 show しても 2・3 手目が欠けない。
  testWidgets('目標設定相当の3手連鎖で2手目以降も出る', (tester) async {
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
                  id: CoachMarkTargetId.goalDailyInputs,
                  child: const SizedBox(
                    width: 100,
                    height: 40,
                    child: Text('daily'),
                  ),
                ),
                CoachMarkTarget(
                  id: CoachMarkTargetId.goalWeeklyDays,
                  child: const SizedBox(
                    width: 100,
                    height: 40,
                    child: Text('weekly'),
                  ),
                ),
                CoachMarkTarget(
                  id: CoachMarkTargetId.goalAutoUpdate,
                  child: const SizedBox(
                    width: 100,
                    height: 40,
                    child: Text('auto'),
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
    final steps = <CoachMarkStep>[
      const CoachMarkStep(
        targetId: CoachMarkTargetId.goalDailyInputs,
        title: 'g1',
        body: 'b1',
        primaryLabel: '次へ',
      ),
      const CoachMarkStep(
        targetId: CoachMarkTargetId.goalWeeklyDays,
        title: 'g2',
        body: 'b2',
        primaryLabel: '次へ',
      ),
      const CoachMarkStep(
        targetId: CoachMarkTargetId.goalAutoUpdate,
        title: 'g3',
        body: 'b3',
        primaryLabel: '閉じる',
      ),
    ];
    unawaited(() async {
      for (var i = 0; i < steps.length; i++) {
        final reason = await CoachMarkLauncher.show(ctx, step: steps[i]);
        reasons.add(reason);
        if (reason != CoachMarkDismissReason.primary) {
          break;
        }
        if (i < steps.length - 1) {
          await WidgetsBinding.instance.endOfFrame;
        }
      }
      done.complete();
    }());

    await _pumpFrames(tester);
    expect(find.text('g1'), findsOneWidget);

    await tester.tap(find.text('次へ'));
    await tester.pump();
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);
    await _pumpFrames(tester);
    expect(find.text('g2'), findsOneWidget, reason: 'reasons=$reasons');

    await tester.tap(find.text('次へ'));
    await tester.pump();
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);
    await _pumpFrames(tester);
    expect(find.text('g3'), findsOneWidget, reason: 'reasons=$reasons');

    await tester.tap(find.text('閉じる'));
    await _pumpFrames(tester, count: 5);
    await done.future;
    expect(reasons, [
      CoachMarkDismissReason.primary,
      CoachMarkDismissReason.primary,
      CoachMarkDismissReason.primary,
    ]);
  });
}
