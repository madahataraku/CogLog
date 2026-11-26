import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:foundation_resources/gen/strings_test_helper.dart';
import 'package:monolith_localization_runtime/monolith_localization_runtime.dart';
import 'package:screen_feature_meter_capture/src/view/meter_tutorial_dismiss_policy.dart';
import 'package:usecase_tutorial/usecase_tutorial.dart';
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

/// 撮影タブ離脱 useEffect と同じ判定で dismiss する。
void _leaveMeterTab(TutorialRuntimeSession session) {
  final kind = session.activeKind;
  if (shouldDismissCoachMarkForMeterTutorial(kind)) {
    CoachMarkLauncher.dismissActive();
    session.clearActive();
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
  // shouldDismissCoachMarkForMeterTutorial + 離脱処理
  //
  // テスト内容:
  // メイン表示中に撮影タブ離脱相当をしてもコーチマークは残る。
  testWidgets('メイン表示中の撮影離脱ではホームのマークを閉じない', (tester) async {
    final registry = CoachMarkRegistry();
    final session = TutorialRuntimeSession()
      ..activeKind = TutorialKind.main
      ..mainStep = TutorialMainStep.homeIntro;
    late BuildContext ctx;

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            ctx = context;
            return CoachMarkTarget(
              id: CoachMarkTargetId.homePeriodTotals,
              child: const SizedBox(width: 200, height: 80, child: Text('t1')),
            );
          },
        ),
      ),
    );
    await tester.pump();

    final future = CoachMarkLauncher.show(
      ctx,
      step: const CoachMarkStep(
        targetId: CoachMarkTargetId.homePeriodTotals,
        title: 'step1',
        body: 'body1',
        primaryLabel: '次へ',
      ),
    );
    await _pumpFrames(tester);
    expect(find.text('step1'), findsOneWidget);

    // 撮影タブを一度開いて戻ったあとの離脱 effect 相当。
    _leaveMeterTab(session);
    await tester.pump();
    await tester.pump(Duration.zero);

    expect(session.activeKind, TutorialKind.main);
    expect(find.text('step1'), findsOneWidget);

    await tester.tap(find.text('次へ'));
    await _pumpFrames(tester);
    expect(await future, CoachMarkDismissReason.primary);
  });

  // テスト対象:
  // shouldDismissCoachMarkForMeterTutorial(camera)
  //
  // テスト内容:
  // 撮影文脈表示中の離脱は forced で閉じる。
  testWidgets('撮影文脈表示中の離脱は dismiss する', (tester) async {
    final registry = CoachMarkRegistry();
    final session = TutorialRuntimeSession()..activeKind = TutorialKind.camera;
    late BuildContext ctx;

    await tester.pumpWidget(
      _wrap(
        registry: registry,
        child: Builder(
          builder: (context) {
            ctx = context;
            return CoachMarkTarget(
              id: CoachMarkTargetId.meterCameraArea,
              child: const SizedBox(width: 200, height: 80, child: Text('cam')),
            );
          },
        ),
      ),
    );
    await tester.pump();

    final future = CoachMarkLauncher.show(
      ctx,
      step: const CoachMarkStep(
        targetId: CoachMarkTargetId.meterCameraArea,
        title: 'camera',
        body: 'body',
        primaryLabel: '閉じる',
      ),
    );
    await _pumpFrames(tester);
    expect(find.text('camera'), findsOneWidget);

    _leaveMeterTab(session);
    await _pumpFrames(tester, count: 5);
    expect(await future, CoachMarkDismissReason.forced);
    expect(session.activeKind, isNull);
    expect(find.text('camera'), findsNothing);
  });
}
